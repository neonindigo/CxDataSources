#if canImport(UIKit)
import UIKit
import Differentiator

/// Implemented by UITableView and UICollectionView to receive batch updates.
public protocol SectionedViewType {
    func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath)
    func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation)
    func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
    func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
    func moveSection(_ from: Int, to: Int)
    func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation)
}

// MARK: - UITableView conformance

extension UITableView: SectionedViewType {
    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        insertRows(at: paths, with: animationStyle)
    }

    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        deleteRows(at: paths, with: animationStyle)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        moveRow(at: from, to: to)
    }

    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        reloadRows(at: paths, with: animationStyle)
    }

    public func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        insertSections(IndexSet(sections), with: animationStyle)
    }

    public func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        deleteSections(IndexSet(sections), with: animationStyle)
    }

    public func moveSection(_ from: Int, to: Int) {
        moveSection(from, toSection: to)
    }

    public func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        reloadSections(IndexSet(sections), with: animationStyle)
    }
}

// MARK: - UICollectionView conformance

extension UICollectionView: SectionedViewType {
    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        insertItems(at: paths)
    }

    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        deleteItems(at: paths)
    }

    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        moveItem(at: from, to: to)
    }

    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableView.RowAnimation) {
        reloadItems(at: paths)
    }

    public func insertSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        insertSections(IndexSet(sections))
    }

    public func deleteSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        deleteSections(IndexSet(sections))
    }

    public func moveSection(_ from: Int, to: Int) {
        moveSection(from, toSection: to)
    }

    public func reloadSections(_ sections: [Int], animationStyle: UITableView.RowAnimation) {
        reloadSections(IndexSet(sections))
    }
}

// MARK: - Default batchUpdates implementation

extension SectionedViewType {
    public func batchUpdates<S: SectionModelType>(
        _ changes: Changeset<S>,
        animationConfiguration: AnimationConfiguration
    ) {
        guard !changes.reloadData else { return }

        deleteSections(changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
        deleteItemsAtIndexPaths(
            changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.deleteAnimation
        )
        insertSections(changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
        insertItemsAtIndexPaths(
            changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.insertAnimation
        )
        for move in changes.movedSections {
            moveSection(move.from, to: move.to)
        }
        for move in changes.movedItems {
            moveItemAtIndexPath(
                IndexPath(item: move.from.itemIndex, section: move.from.sectionIndex),
                to: IndexPath(item: move.to.itemIndex, section: move.to.sectionIndex)
            )
        }
        reloadSections(changes.updatedSections, animationStyle: animationConfiguration.reloadAnimation)
        reloadItemsAtIndexPaths(
            changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
            animationStyle: animationConfiguration.reloadAnimation
        )
    }
}
#endif
