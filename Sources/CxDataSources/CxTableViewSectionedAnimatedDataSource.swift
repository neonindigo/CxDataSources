#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Binds a Publisher<[Section], Never> using Differentiator's 3-phase diff + performBatchUpdates.
open class CxTableViewSectionedAnimatedDataSource<Section: AnimatableSectionModelType>
    : TableViewSectionedDataSource<Section> {
    public typealias DecideViewTransition = (CxTableViewSectionedAnimatedDataSource<Section>, UITableView, [Changeset<Section>]) -> ViewTransition
    public var animationConfiguration: AnimationConfiguration
    public var decideViewTransition: DecideViewTransition

    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil }
    ) {
        self.animationConfiguration = animationConfiguration
        self.decideViewTransition = decideViewTransition
        super.init(
            configureCell: configureCell,
            titleForHeaderInSection: titleForHeaderInSection,
            titleForFooterInSection: titleForFooterInSection
        )
    }

    public func bind(to tableView: UITableView) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        fatalError("stub")
    }
}
#endif
