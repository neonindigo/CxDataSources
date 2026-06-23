#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Binds a Publisher<[Section], Never> to a UITableView using reloadData().
open class CxTableViewSectionedReloadDataSource<Section: SectionModelType>
    : TableViewSectionedDataSource<Section> {

    public func bind(to tableView: UITableView) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        return { [weak self] publisher in
            guard let self else { return AnyCancellable({}) }
            tableView.dataSource = self
            return publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self, weak tableView] sections in
                    guard let self, let tableView else { return }
                    self.setSections(sections)
                    tableView.reloadData()
                }
        }
    }
}
#endif
