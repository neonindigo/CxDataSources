import XCTest
import Combine
import Differentiator
@testable import CxDataSources

// MARK: - Shared test fixtures

struct StringSection: SectionModelType {
    var model: String
    var items: [String]

    init(model: String, items: [String]) {
        self.model = model
        self.items = items
    }

    init(original: StringSection, items: [String]) {
        self = original
        self.items = items
    }
}

struct IntItem: IdentifiableType, Equatable {
    var identity: Int
}

struct AnimatableSection: AnimatableSectionModelType {
    typealias Item = IntItem
    typealias Identity = String

    var identity: String
    var items: [IntItem]

    init(identity: String, items: [IntItem]) {
        self.identity = identity
        self.items = items
    }

    init(original: AnimatableSection, items: [IntItem]) {
        self = original
        self.items = items
    }
}

// MARK: - SectionModelTests

final class SectionModelTests: XCTestCase {
    func testSectionModelStoresModelAndItems() {
        let section = SectionModel(model: "header", items: [1, 2, 3])
        XCTAssertEqual(section.model, "header")
        XCTAssertEqual(section.items, [1, 2, 3])
    }

    func testAnimatableSectionModelIdentity() {
        struct Header: IdentifiableType {
            var identity: String
        }
        let section = AnimatableSectionModel(model: Header(identity: "h1"), items: [IntItem(identity: 42)])
        XCTAssertEqual(section.identity, "h1")
        XCTAssertEqual(section.items.count, 1)
        XCTAssertEqual(section.items[0].identity, 42)
    }

    func testChangesetInitialValueHasReloadDataTrue() {
        let sections = [AnimatableSection(identity: "s1", items: [])]
        let changeset = Changeset<AnimatableSection>.initialValue(sections)
        XCTAssertTrue(changeset.reloadData)
        XCTAssertEqual(changeset.finalSections.count, 1)
    }
}

// MARK: - DifferentiatorIntegrationTests

final class DifferentiatorIntegrationTests: XCTestCase {
    func testDiffProducesInsertedItems() throws {
        let initial = [AnimatableSection(identity: "s1", items: [IntItem(identity: 1)])]
        let final = [AnimatableSection(identity: "s1", items: [IntItem(identity: 1), IntItem(identity: 2)])]
        let changesets = try Diff.differencesForSectionedView(initialSections: initial, finalSections: final)
        let allInserted = changesets.flatMap { $0.insertedItems }
        XCTAssertTrue(allInserted.contains(where: { $0.sectionIndex == 0 && $0.itemIndex == 1 }))
    }

    func testDiffProducesDeletedSections() throws {
        let initial = [
            AnimatableSection(identity: "s1", items: []),
            AnimatableSection(identity: "s2", items: [])
        ]
        let final = [AnimatableSection(identity: "s1", items: [])]
        let changesets = try Diff.differencesForSectionedView(initialSections: initial, finalSections: final)
        let allDeleted = changesets.flatMap { $0.deletedSections }
        XCTAssertTrue(allDeleted.contains(1))
    }

    func testDiffThrowsOnDuplicateItemIdentity() {
        let initial = [AnimatableSection(identity: "s1", items: [IntItem(identity: 1)])]
        let final = [AnimatableSection(identity: "s1", items: [IntItem(identity: 1), IntItem(identity: 1)])]
        XCTAssertThrowsError(
            try Diff.differencesForSectionedView(initialSections: initial, finalSections: final)
        )
    }
}

// MARK: - UIKit tests

#if canImport(UIKit)
import UIKit

// MARK: ReloadDataSourceTests

final class ReloadDataSourceTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testBindSetsDataSourceOnTableView() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = CxTableViewSectionedReloadDataSource<StringSection>(
            configureCell: { _, tv, ip, _ in UITableViewCell() }
        )
        let subject = PassthroughSubject<[StringSection], Never>()
        subject.eraseToAnyPublisher().bind(to: dataSource.bind(to: tableView)).store(in: &cancellables)
        XCTAssertTrue(tableView.dataSource === dataSource)
    }

    func testFirstEmissionUpdatesSections() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = CxTableViewSectionedReloadDataSource<StringSection>(
            configureCell: { _, _, _, _ in UITableViewCell() }
        )
        let subject = PassthroughSubject<[StringSection], Never>()
        subject.eraseToAnyPublisher().bind(to: dataSource.bind(to: tableView)).store(in: &cancellables)

        let sections = [StringSection(model: "A", items: ["1", "2"])]
        subject.send(sections)

        let exp = expectation(description: "sections updated")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(dataSource.sectionModels.count, 1)
        XCTAssertEqual(dataSource.sectionModels[0].items, ["1", "2"])
    }

    func testCancellingStopsFutureUpdates() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = CxTableViewSectionedReloadDataSource<StringSection>(
            configureCell: { _, _, _, _ in UITableViewCell() }
        )
        let subject = PassthroughSubject<[StringSection], Never>()
        var cancellable: AnyCancellable? = subject.eraseToAnyPublisher().bind(to: dataSource.bind(to: tableView))

        subject.send([StringSection(model: "A", items: ["x"])])
        let exp1 = expectation(description: "first emission processed")
        DispatchQueue.main.async { exp1.fulfill() }
        wait(for: [exp1], timeout: 1.0)

        cancellable = nil
        subject.send([StringSection(model: "B", items: ["y", "z"])])

        let exp2 = expectation(description: "second send idle")
        DispatchQueue.main.async { exp2.fulfill() }
        wait(for: [exp2], timeout: 1.0)

        XCTAssertEqual(dataSource.sectionModels.count, 1)
        XCTAssertEqual(dataSource.sectionModels[0].model, "A")
    }

    func testBindViaCxItemsExtension() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = CxTableViewSectionedReloadDataSource<StringSection>(
            configureCell: { _, _, _, _ in UITableViewCell() }
        )
        let subject = PassthroughSubject<[StringSection], Never>()
        subject.eraseToAnyPublisher()
            .bind(to: tableView.cx.items(dataSource: dataSource))
            .store(in: &cancellables)

        subject.send([StringSection(model: "Z", items: ["a", "b", "c"])])
        let exp = expectation(description: "sections via cx.items")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(dataSource.sectionModels.count, 1)
        XCTAssertEqual(dataSource.sectionModels[0].items.count, 3)
    }
}

// MARK: AnimatedDataSourceTests

final class AnimatedDataSourceTests: XCTestCase {
    private var cancellables = Set<AnyCancellable>()

    override func tearDown() {
        cancellables.removeAll()
        super.tearDown()
    }

    func testFirstEmissionReloadsData() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = CxTableViewSectionedAnimatedDataSource<AnimatableSection>(
            configureCell: { _, _, _, _ in UITableViewCell() }
        )
        let subject = PassthroughSubject<[AnimatableSection], Never>()
        subject.eraseToAnyPublisher().bind(to: dataSource.bind(to: tableView)).store(in: &cancellables)

        let sections = [AnimatableSection(identity: "s1", items: [IntItem(identity: 1)])]
        subject.send(sections)

        let exp = expectation(description: "first emission processed")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(dataSource.sectionModels.count, 1)
        XCTAssertEqual(dataSource.sectionModels[0].identity, "s1")
    }

    func testSecondEmissionUpdatesSections() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = CxTableViewSectionedAnimatedDataSource<AnimatableSection>(
            decideViewTransition: { _, _, _ in .reload },
            configureCell: { _, _, _, _ in UITableViewCell() }
        )
        let subject = PassthroughSubject<[AnimatableSection], Never>()
        subject.eraseToAnyPublisher().bind(to: dataSource.bind(to: tableView)).store(in: &cancellables)

        subject.send([AnimatableSection(identity: "s1", items: [IntItem(identity: 1)])])
        var exp = expectation(description: "first emission")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        subject.send([AnimatableSection(identity: "s1", items: [IntItem(identity: 1), IntItem(identity: 2)])])
        exp = expectation(description: "second emission")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(dataSource.sectionModels[0].items.count, 2)
    }

    func testDiffFailureFallsBackToReload() {
        let tableView = UITableView(frame: .zero, style: .plain)
        let dataSource = CxTableViewSectionedAnimatedDataSource<AnimatableSection>(
            configureCell: { _, _, _, _ in UITableViewCell() }
        )
        let subject = PassthroughSubject<[AnimatableSection], Never>()
        subject.eraseToAnyPublisher().bind(to: dataSource.bind(to: tableView)).store(in: &cancellables)

        // First emission establishes baseline
        subject.send([AnimatableSection(identity: "s1", items: [IntItem(identity: 1)])])
        var exp = expectation(description: "first emission")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        // Second emission with duplicate item identities causes diff to throw → fallback reload
        subject.send([AnimatableSection(identity: "s1", items: [IntItem(identity: 1), IntItem(identity: 1)])])
        exp = expectation(description: "fallback reload")
        DispatchQueue.main.async { exp.fulfill() }
        wait(for: [exp], timeout: 1.0)

        XCTAssertEqual(dataSource.sectionModels[0].items.count, 2)
    }
}
#endif
