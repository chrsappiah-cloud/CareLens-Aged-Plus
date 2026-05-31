import XCTest
import Foundation
import SwiftUI
@testable import CarelensAged

// MARK: - Display + Validate ALL Enum Units

final class E2EAccessTierTests: XCTestCase {
    func testAllTiersHaveLimits() {
        for tier in AccessTier.allCases {
            XCTAssertGreaterThanOrEqual(tier.maxClients, 1, "\(tier.rawValue) must allow clients")
            XCTAssertFalse(tier.features.isEmpty, "\(tier.rawValue) must have features")
        }
    }
    func testTierHierarchy() {
        let f = AccessTier.free.maxClients
        XCTAssertLessThan(f, AccessTier.starter.maxClients)
        XCTAssertLessThan(AccessTier.starter.maxClients, AccessTier.professional.maxClients)
        XCTAssertEqual(AccessTier.enterprise.maxClients, Int.max)
    }
}

final class E2EAppFeatureTests: XCTestCase {
    func testAllFeaturesHaveIcons() {
        for f in AppFeature.allCases {
            XCTAssertFalse(f.rawValue.isEmpty)
            XCTAssertFalse(f.icon.isEmpty, "\(f.rawValue) missing icon")
        }
    }
    func testFeatureCounts() {
        XCTAssertEqual(AccessTier.free.features.count, 3)
        XCTAssertEqual(AccessTier.starter.features.count, 8)
        XCTAssertEqual(AccessTier.professional.features.count, 15)
        XCTAssertEqual(AccessTier.enterprise.features.count, AppFeature.allCases.count)
    }
    func testTierSubset() {
        let free = Set(AccessTier.free.features)
        let starter = Set(AccessTier.starter.features)
        let pro = Set(AccessTier.professional.features)
        let ent = Set(AccessTier.enterprise.features)
        XCTAssertTrue(free.isSubset(of: starter))
        XCTAssertTrue(starter.isSubset(of: pro))
        XCTAssertTrue(pro.isSubset(of: ent))
    }
}

final class E2EUserRoleTests: XCTestCase {
    func testAllRolesHaveAccess() {
        for role in UserRole.allCases {
            XCTAssertFalse(role.rawValue.isEmpty)
            XCTAssertGreaterThan(role.accessLevel, 0)
        }
    }
    func testAccessHierarchy() {
        let sorted = UserRole.allCases.sorted { $0.accessLevel > $1.accessLevel }
        XCTAssertEqual(sorted.first, .admin)
        XCTAssertEqual(sorted.last, .externalClinician)
    }
}

final class E2EAssessmentStatusTests: XCTestCase {
    func testAllStatusesHaveColors() {
        for s in AssessmentStatus.allCases {
            XCTAssertFalse(s.rawValue.isEmpty)
            XCTAssertNotEqual(s.color, .clear)
        }
    }
}

final class E2EMonitoringEventTypeTests: XCTestCase {
    func testAllEventsHaveIcons() {
        for e in MonitoringEventType.allCases {
            XCTAssertFalse(e.rawValue.isEmpty)
            XCTAssertFalse(e.icon.isEmpty)
        }
    }
}

final class E2ENeuroWatchBandTests: XCTestCase {
    func testAllBandsHaveActions() {
        for b in NeuroWatchBand.allCases {
            XCTAssertFalse(b.rawValue.isEmpty)
            XCTAssertFalse(b.color.isEmpty)
            XCTAssertFalse(b.suggestedAction.isEmpty)
        }
    }
}

final class E2EReportTypeTests: XCTestCase {
    func testAllTypes() { ReportType.allCases.forEach { XCTAssertFalse($0.rawValue.isEmpty) } }
}

final class E2ECKZoneNameTests: XCTestCase {
    func testAllZones() { CKZoneName.allCases.forEach { XCTAssertFalse($0.rawValue.isEmpty) } }
}

final class E2ESyncModelTests: XCTestCase {
    func testRecordTypes() {
        let types: [SyncRecordType] = [.client, .assessment, .carePlan, .monitoringEvent]
        for t in types { XCTAssertFalse(t.rawValue.isEmpty) }
    }
    func testDestinations() { SyncDestination.allCases.forEach { XCTAssertFalse($0.rawValue.isEmpty) } }
    func testSyncValueRoundTrip() throws {
        let vals: [SyncValue] = [.string("a"), .int(1), .double(1.5), .bool(true), .stringArray(["x"]), .null]
        for v in vals {
            let d = try JSONEncoder().encode(v)
            XCTAssertEqual(v, try JSONDecoder().decode(SyncValue.self, from: d))
        }
    }
    func testSyncRecordEncode() throws {
        let c = ClientProfile(firstName: "T", lastName: "U", dateOfBirth: .now)
        let r = SyncRecord.from(client: c)
        let d = try JSONEncoder().encode(r)
        let dec = try JSONDecoder().decode(SyncRecord.self, from: d)
        XCTAssertEqual(dec.id, r.id)
        XCTAssertEqual(dec.recordType, .client)
    }
    func testStepResult() {
        let s = SyncStepResult.success(.supabasePrimary, count: 5)
        XCTAssertTrue(s.succeeded)
        XCTAssertEqual(s.recordsWritten, 5)
        let f = SyncStepResult.failure(.cloudflare, message: "err")
        XCTAssertFalse(f.succeeded)
    }
    func testPipelineResult() {
        let p = SyncStepResult.success(.supabasePrimary, count: 1)
        let ck = SyncStepResult.success(.cloudKit, count: 1)
        let cf = SyncStepResult.success(.cloudflare, count: 1)
        let r = SyncPipelineResult(primary: p, cloudKit: ck, cloudflare: cf, completedAt: .now)
        XCTAssertTrue(r.primarySucceeded)
        XCTAssertTrue(r.allBackupsSucceeded)
    }
}
