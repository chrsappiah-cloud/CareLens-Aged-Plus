import Foundation
import CloudKit

enum CKZoneName: String, CaseIterable {
    case clients = "ClientZone"
    case assessments = "AssessmentZone"
    case carePlans = "CarePlanZone"
    case reports = "ReportZone"
    case careCircle = "CareCircleZone"
    case audit = "AuditZone"
}

enum CKRecordType: String {
    case client = "CKClient"
    case assessment = "CKAssessment"
    case assessmentSection = "CKAssessmentSection"
    case monitoringEvent = "CKMonitoringEvent"
    case carePlan = "CKCarePlan"
    case goal = "CKGoal"
    case intervention = "CKIntervention"
    case report = "CKReport"
    case caregiver = "CKCaregiver"
    case acpDocument = "CKACPDocument"
    case spiritualProfile = "CKSpiritualProfile"
}

enum CloudKitError: Error, LocalizedError {
    case disabled

    var errorDescription: String? {
        "iCloud / CloudKit is not available in this environment."
    }
}

actor CloudKitManager {
    private let privateDatabase: CKDatabase?
    let isEnabled: Bool

    init(containerIdentifier: String = AppEnvironment.cloudKitContainerID) {
        isEnabled = AppEnvironment.shouldUseCloudKit
        if isEnabled {
            let container = CKContainer(identifier: containerIdentifier)
            privateDatabase = container.privateCloudDatabase
        } else {
            privateDatabase = nil
        }
    }

    private func requireDatabase() throws -> CKDatabase {
        guard let privateDatabase else { throw CloudKitError.disabled }
        return privateDatabase
    }

    // MARK: - Zone Management

    func createCustomZones() async throws {
        guard isEnabled else { return }
        let db = try requireDatabase()
        let zones = CKZoneName.allCases.map { CKRecordZone(zoneName: $0.rawValue) }
        for zone in zones {
            do {
                _ = try await db.save(zone)
            } catch let error as CKError where error.code == .serverRecordChanged {
                continue
            }
        }
    }

    // MARK: - Client Operations

    func saveClient(_ client: ClientProfile) async throws {
        let db = try requireDatabase()
        let zoneID = CKRecordZone.ID(zoneName: CKZoneName.clients.rawValue)
        let recordID = CKRecord.ID(recordName: client.id, zoneID: zoneID)
        let record = CKRecord(recordType: CKRecordType.client.rawValue, recordID: recordID)

        record["firstName"] = client.firstName
        record["lastName"] = client.lastName
        record["dateOfBirth"] = client.dateOfBirth
        record["gender"] = client.gender
        record["preferredLanguage"] = client.preferredLanguage
        record["culturalIdentity"] = client.culturalIdentity
        record["consentStatus"] = client.consentStatus
        record["referralSource"] = client.referralSource
        record["presentingConcerns"] = client.presentingConcerns
        record["interpreterNeeded"] = client.interpreterNeeded ? 1 : 0
        record["nominatedDecisionMaker"] = client.nominatedDecisionMaker
        record["safetyFlags"] = client.safetyFlags
        record["createdAt"] = client.createdAt
        record["updatedAt"] = Date.now

        _ = try await db.save(record)
    }

    func fetchClients() async throws -> [CKRecord] {
        let db = try requireDatabase()
        let zoneID = CKRecordZone.ID(zoneName: CKZoneName.clients.rawValue)
        let query = CKQuery(recordType: CKRecordType.client.rawValue, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "lastName", ascending: true)]

        let (results, _) = try await db.records(matching: query, inZoneWith: zoneID)
        return results.compactMap { try? $0.1.get() }
    }

    // MARK: - Assessment Operations

    func saveAssessment(_ assessment: AssessmentSession) async throws {
        let db = try requireDatabase()
        let zoneID = CKRecordZone.ID(zoneName: CKZoneName.assessments.rawValue)
        let recordID = CKRecord.ID(recordName: assessment.id, zoneID: zoneID)
        let record = CKRecord(recordType: CKRecordType.assessment.rawValue, recordID: recordID)

        record["clientID"] = assessment.clientID
        record["type"] = assessment.assessmentType
        record["status"] = assessment.status
        record["assessorRole"] = assessment.assessorRole
        record["cognitionScore"] = assessment.cognitionScore
        record["moodScore"] = assessment.moodScore
        record["anxietyScore"] = assessment.anxietyScore
        record["deliriumRiskScore"] = assessment.deliriumRiskScore
        record["adlScore"] = assessment.adlScore
        record["caregivingStressScore"] = assessment.caregivingStressScore
        record["createdAt"] = assessment.createdAt
        record["updatedAt"] = Date.now

        _ = try await db.save(record)
    }

    // MARK: - Care Plan Operations

    func saveCarePlan(_ plan: CarePlan) async throws {
        let db = try requireDatabase()
        let zoneID = CKRecordZone.ID(zoneName: CKZoneName.carePlans.rawValue)
        let recordID = CKRecord.ID(recordName: plan.id, zoneID: zoneID)
        let record = CKRecord(recordType: CKRecordType.carePlan.rawValue, recordID: recordID)

        record["clientID"] = plan.clientID
        record["strengths"] = plan.strengths
        record["priorityProblems"] = plan.priorityProblems
        record["goals"] = plan.goals
        record["interventions"] = plan.interventions
        record["immediateActions"] = plan.immediateActions
        record["spiritualSupport"] = plan.spiritualSupport
        record["serviceReferrals"] = plan.serviceReferrals
        record["nextReviewDate"] = plan.nextReviewDate
        record["updatedAt"] = Date.now

        _ = try await db.save(record)
    }

    // MARK: - Sync Engine

    func performFullSync(
        localClients: [ClientProfile],
        localAssessments: [AssessmentSession],
        localPlans: [CarePlan]
    ) async throws {
        guard isEnabled else { return }
        for client in localClients {
            try await saveClient(client)
        }
        for assessment in localAssessments {
            try await saveAssessment(assessment)
        }
        for plan in localPlans {
            try await saveCarePlan(plan)
        }
    }

    func fetchChanges(since token: CKServerChangeToken?) async throws -> (records: [CKRecord], deletedIDs: [CKRecord.ID], newToken: CKServerChangeToken?) {
        guard isEnabled else { return ([], [], token) }
        let db = try requireDatabase()

        var changedRecords: [CKRecord] = []
        var deletedIDs: [CKRecord.ID] = []
        var newToken: CKServerChangeToken?

        let zones = CKZoneName.allCases.map { CKRecordZone.ID(zoneName: $0.rawValue) }

        for zoneID in zones {
            let config = CKFetchRecordZoneChangesOperation.ZoneConfiguration()
            config.previousServerChangeToken = token

            let operation = CKFetchRecordZoneChangesOperation(recordZoneIDs: [zoneID], configurationsByRecordZoneID: [zoneID: config])

            operation.recordWasChangedBlock = { _, result in
                if let record = try? result.get() {
                    changedRecords.append(record)
                }
            }

            operation.recordWithIDWasDeletedBlock = { recordID, _ in
                deletedIDs.append(recordID)
            }

            operation.recordZoneFetchResultBlock = { _, result in
                if case .success(let (serverToken, _, _)) = result {
                    newToken = serverToken
                }
            }

            db.add(operation)
        }

        return (changedRecords, deletedIDs, newToken)
    }

    // MARK: - Subscriptions

    func setupPushSubscriptions() async throws {
        guard isEnabled else { return }
        let db = try requireDatabase()
        for zone in CKZoneName.allCases {
            let zoneID = CKRecordZone.ID(zoneName: zone.rawValue)
            let subscription = CKRecordZoneSubscription(zoneID: zoneID, subscriptionID: "sub_\(zone.rawValue)")

            let notificationInfo = CKSubscription.NotificationInfo()
            notificationInfo.shouldSendContentAvailable = true
            subscription.notificationInfo = notificationInfo

            _ = try await db.save(subscription)
        }
    }

    // MARK: - Conflict Resolution

    func resolveConflict(local: CKRecord, server: CKRecord) -> CKRecord {
        let localDate = local["updatedAt"] as? Date ?? .distantPast
        let serverDate = server["updatedAt"] as? Date ?? .distantPast
        return serverDate > localDate ? server : local
    }

    func deleteRecord(id: String, zone: CKZoneName) async throws {
        let db = try requireDatabase()
        let zoneID = CKRecordZone.ID(zoneName: zone.rawValue)
        let recordID = CKRecord.ID(recordName: id, zoneID: zoneID)
        try await db.deleteRecord(withID: recordID)
    }
}
