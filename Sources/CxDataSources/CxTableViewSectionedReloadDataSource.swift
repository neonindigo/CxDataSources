#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Binds a Publisher<[Section], Never> to a UITableView using reloadData().
open class CxTableViewSectionedReloadDataSource<Section: SectionModelType>
    : TableViewSectionedDataSource<Section> {
    public func bind(to tableView: UITableView) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        // stub
        fatalError("stub")
    }
}
#endif
