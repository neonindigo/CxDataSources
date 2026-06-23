#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Binds a Publisher<[Section], Never> to a UICollectionView using reloadData().
open class CxCollectionViewSectionedReloadDataSource<Section: SectionModelType>
    : CollectionViewSectionedDataSource<Section> {
    public func bind(to collectionView: UICollectionView) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        fatalError("stub")
    }
}
#endif
