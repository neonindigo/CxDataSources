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

extension SectionedViewType {
    func batchUpdates<S: SectionModelType>(_ changes: [Changeset<S>], animationConfiguration: AnimationConfiguration) {
        // stub
    }
}
#endif
