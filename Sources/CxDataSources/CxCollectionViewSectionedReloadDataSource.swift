#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Binds a Publisher<[Section], Never> to a UICollectionView using reloadData().
open class CxCollectionViewSectionedReloadDataSource<Section: SectionModelType>
    : CollectionViewSectionedDataSource<Section> {

    public func bind(to collectionView: UICollectionView) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        return { [weak self] publisher in
            guard let self else { return AnyCancellable({}) }
            collectionView.dataSource = self
            return publisher
                .receive(on: DispatchQueue.main)
                .sink { [weak self, weak collectionView] sections in
                    guard let self, let collectionView else { return }
                    self.setSections(sections)
                    collectionView.reloadData()
                    collectionView.collectionViewLayout.invalidateLayout()
                }
        }
    }
}
#endif
