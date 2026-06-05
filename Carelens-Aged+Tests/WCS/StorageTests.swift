import SwiftData
import XCTest
@testable import CarelensAged

/// WCS: Storage — SwiftData save, reload, and empty-state behavior.
@MainActor
final class StorageTests: XCTestCase {

    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() {
        super.setUp()
        container = WCSArrange.inMemoryModelContainer()
        context = container.mainContext
    }

    override func tearDown() {
        context = nil
        container = nil
        super.tearDown()
    }

    func testZero_suiteWiring() {
        WCSTestZero.assertSuiteWiring(in: self)
    }

    func test_insertClientProfile_canFetchByID() throws {
        let client = TestFixtures.client()
        context.insert(client)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<ClientProfile>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.id, client.id)
    }

    func test_insertAssessmentSession_persistsStatus() throws {
        let assessment = AssessmentSession(
            clientID: "c1",
            assessmentType: "NeuroWatch",
            status: "Completed",
            assessorRole: "Clinician"
        )
        context.insert(assessment)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<AssessmentSession>())
        XCTAssertEqual(fetched.first?.assessmentStatus, .completed)
    }

    func test_emptyStore_returnsZeroClients() throws {
        let fetched = try context.fetch(FetchDescriptor<ClientProfile>())
        XCTAssertTrue(fetched.isEmpty)
    }
}
