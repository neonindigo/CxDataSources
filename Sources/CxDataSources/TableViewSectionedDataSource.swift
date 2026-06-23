#if canImport(UIKit)
import UIKit
import Differentiator

open class TableViewSectionedDataSource<Section: SectionModelType>: NSObject, UITableViewDataSource {
    public typealias Item = Section.Item
    public typealias ConfigureCell = (TableViewSectionedDataSource<Section>, UITableView, IndexPath, Item) -> UITableViewCell
    public typealias TitleForHeaderInSection = (TableViewSectionedDataSource<Section>, Int) -> String?
    public typealias TitleForFooterInSection = (TableViewSectionedDataSource<Section>, Int) -> String?
    public typealias CanEditRowAtIndexPath = (TableViewSectionedDataSource<Section>, IndexPath) -> Bool
    public typealias CanMoveRowAtIndexPath = (TableViewSectionedDataSource<Section>, IndexPath) -> Bool

    public var configureCell: ConfigureCell
    public var titleForHeaderInSection: TitleForHeaderInSection
    public var titleForFooterInSection: TitleForFooterInSection
    public var canEditRowAtIndexPath: CanEditRowAtIndexPath
    public var canMoveRowAtIndexPath: CanMoveRowAtIndexPath

    public init(
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
    ) {
        self.configureCell = configureCell
        self.titleForHeaderInSection = titleForHeaderInSection
        self.titleForFooterInSection = titleForFooterInSection
        self.canEditRowAtIndexPath = canEditRowAtIndexPath
        self.canMoveRowAtIndexPath = canMoveRowAtIndexPath
    }

    open var sectionModels: [Section] = []

    open subscript(section: Int) -> Section {
        sectionModels[section]
    }

    open subscript(indexPath: IndexPath) -> Item {
        sectionModels[indexPath.section].items[indexPath.row]
    }

    open func setSections(_ sections: [Section]) {
        sectionModels = sections
    }

    open func model(at indexPath: IndexPath) throws -> Any {
        self[indexPath]
    }

    // MARK: - UITableViewDataSource

    public func numberOfSections(in tableView: UITableView) -> Int {
        sectionModels.count
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sectionModels[section].items.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        configureCell(self, tableView, indexPath, self[indexPath])
    }

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        titleForHeaderInSection(self, section)
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        titleForFooterInSection(self, section)
    }

    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        canEditRowAtIndexPath(self, indexPath)
    }

    public func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        canMoveRowAtIndexPath(self, indexPath)
    }

    public func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        // stub
    }
}
#endif
