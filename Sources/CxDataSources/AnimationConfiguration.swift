#if canImport(UIKit)
import UIKit

/// Controls the row/item animations used by animated data sources.
public struct AnimationConfiguration {
    public let insertAnimation: UITableView.RowAnimation
    public let reloadAnimation: UITableView.RowAnimation
    public let deleteAnimation: UITableView.RowAnimation

    public init(
        insertAnimation: UITableView.RowAnimation = .automatic,
        reloadAnimation: UITableView.RowAnimation = .automatic,
        deleteAnimation: UITableView.RowAnimation = .automatic
    ) {
        self.insertAnimation = insertAnimation
        self.reloadAnimation = reloadAnimation
        self.deleteAnimation = deleteAnimation
    }
}
#endif
