#if canImport(UIKit)
import UIKit
import Differentiator

open class CollectionViewSectionedDataSource<Section: SectionModelType>: NSObject, UICollectionViewDataSource {
    public typealias Item = Section.Item
    public typealias ConfigureCell = (CollectionViewSectionedDataSource<Section>, UICollectionView, IndexPath, Item) -> UICollectionViewCell
    public typealias ConfigureSupplementaryView = (CollectionViewSectionedDataSource<Section>, UICollectionView, String, IndexPath) -> UICollectionReusableView
    public typealias MoveItem = (CollectionViewSectionedDataSource<Section>, IndexPath, IndexPath) -> Void
    public typealias CanMoveItemAtIndexPath = (CollectionViewSectionedDataSource<Section>, IndexPath) -> Bool

    public var configureCell: ConfigureCell
    public var configureSupplementaryView: ConfigureSupplementaryView
    public var moveItem: MoveItem
    public var canMoveItemAtIndexPath: CanMoveItemAtIndexPath

    public init(
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: @escaping ConfigureSupplementaryView = { _, _, _, _ in fatalError("supplementaryView not configured") },
        moveItem: @escaping MoveItem = { _, _, _ in },
        canMoveItemAtIndexPath: @escaping CanMoveItemAtIndexPath = { _, _ in false }
    ) {
        self.configureCell = configureCell
        self.configureSupplementaryView = configureSupplementaryView
        self.moveItem = moveItem
        self.canMoveItemAtIndexPath = canMoveItemAtIndexPath
    }

    open var sectionModels: [Section] = []

    open subscript(section: Int) -> Section {
        sectionModels[section]
    }

    open subscript(indexPath: IndexPath) -> Item {
        sectionModels[indexPath.section].items[indexPath.item]
    }

    open func setSections(_ sections: [Section]) {
        sectionModels = sections
    }

    open func model(at indexPath: IndexPath) throws -> Any {
        self[indexPath]
    }

    // MARK: - UICollectionViewDataSource

    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        sectionModels.count
    }

    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        sectionModels[section].items.count
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        configureCell(self, collectionView, indexPath, self[indexPath])
    }

    public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        configureSupplementaryView(self, collectionView, kind, indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        canMoveItemAtIndexPath(self, indexPath)
    }

    public func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        moveItem(self, sourceIndexPath, destinationIndexPath)
    }
}
#endif
