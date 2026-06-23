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
        fatalError("stub")
    }
}
#endif
