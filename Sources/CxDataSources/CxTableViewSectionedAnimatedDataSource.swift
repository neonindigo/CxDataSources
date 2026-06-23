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
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
        moveItem: @escaping MoveItem = { _, _, _ in }
    ) {
        self.animationConfiguration = animationConfiguration
        self.decideViewTransition = decideViewTransition
        super.init(
            configureCell: configureCell,
            titleForHeaderInSection: titleForHeaderInSection,
            titleForFooterInSection: titleForFooterInSection,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath,
            moveItem: moveItem
        )
    }

    public func bind(to tableView: UITableView) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        return { [weak self] publisher in
            guard let self else { return AnyCancellable({}) }
            tableView.dataSource = self
            var isFirstEmission = true
            return publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self, weak tableView] newSections in
                    guard let self, let tableView else { return }
                    if isFirstEmission {
                        isFirstEmission = false
                        self.setSections(newSections)
                        tableView.reloadData()
                        return
                    }
                    let previousSections = self.sectionModels
                    do {
                        let changesets = try Diff.differencesForSectionedView(
                            initialSections: previousSections,
                            finalSections: newSections
                        )
                        switch self.decideViewTransition(self, tableView, changesets) {
                        case .reload:
                            self.setSections(newSections)
                            tableView.reloadData()
                        case .animated:
                            for changeset in changesets {
                                self.setSections(changeset.finalSections)
                                tableView.performBatchUpdates {
                                    tableView.batchUpdates(changeset, animationConfiguration: self.animationConfiguration)
                                }
                            }
                        }
                    } catch {
                        self.setSections(newSections)
                        tableView.reloadData()
                    }
                }
        }
    }
}
#endif
