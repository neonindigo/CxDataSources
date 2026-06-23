#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Cx namespace wrapper.
public struct CxTableViewWrapper {
    let tableView: UITableView
}

extension UITableView {
    public var cx: CxTableViewWrapper { CxTableViewWrapper(tableView: self) }
}

extension CxTableViewWrapper {
    /// Returns a function: bind a Publisher<[Section], Never> and get back an AnyCancellable.
    public func items<Section: SectionModelType>(
        dataSource: CxTableViewSectionedReloadDataSource<Section>
    ) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        dataSource.bind(to: tableView)
    }

    public func items<Section: AnimatableSectionModelType>(
        dataSource: CxTableViewSectionedAnimatedDataSource<Section>
    ) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        dataSource.bind(to: tableView)
    }
}
#endif
