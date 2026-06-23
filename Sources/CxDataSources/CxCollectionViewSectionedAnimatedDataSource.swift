#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Binds a Publisher<[Section], Never> using Differentiator's 3-phase diff + performBatchUpdates.
open class CxCollectionViewSectionedAnimatedDataSource<Section: AnimatableSectionModelType>
    : CollectionViewSectionedDataSource<Section> {

    public typealias DecideViewTransition = (CxCollectionViewSectionedAnimatedDataSource<Section>, UICollectionView, [Changeset<Section>]) -> ViewTransition

    public var animationConfiguration: AnimationConfiguration
    public var decideViewTransition: DecideViewTransition

    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideViewTransition: @escaping DecideViewTransition = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        configureSupplementaryView: @escaping ConfigureSupplementaryView = { _, _, _, _ in fatalError("supplementaryView not configured") }
    ) {
        self.animationConfiguration = animationConfiguration
        self.decideViewTransition = decideViewTransition
        super.init(
            configureCell: configureCell,
            configureSupplementaryView: configureSupplementaryView
        )
    }

    public func bind(to collectionView: UICollectionView) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        return { [weak self] publisher in
            guard let self else { return AnyCancellable({}) }
            collectionView.dataSource = self
            var isFirstEmission = true
            return publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self, weak collectionView] newSections in
                    guard let self, let collectionView else { return }
                    if isFirstEmission {
                        isFirstEmission = false
                        self.setSections(newSections)
                        collectionView.reloadData()
                        collectionView.collectionViewLayout.invalidateLayout()
                        return
                    }
                    let previousSections = self.sectionModels
                    do {
                        let changesets = try Diff.differencesForSectionedView(
                            initialSections: previousSections,
                            finalSections: newSections
                        )
                        switch self.decideViewTransition(self, collectionView, changesets) {
                        case .reload:
                            self.setSections(newSections)
                            collectionView.reloadData()
                            collectionView.collectionViewLayout.invalidateLayout()
                        case .animated:
                            for changeset in changesets {
                                self.setSections(changeset.finalSections)
                                collectionView.performBatchUpdates {
                                    collectionView.batchUpdates(changeset, animationConfiguration: self.animationConfiguration)
                                }
                            }
                        }
                    } catch {
                        self.setSections(newSections)
                        collectionView.reloadData()
                        collectionView.collectionViewLayout.invalidateLayout()
                    }
                }
        }
    }
}
#endif
