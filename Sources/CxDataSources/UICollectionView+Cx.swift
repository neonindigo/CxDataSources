#if canImport(UIKit)
import UIKit
import Combine
import Differentiator

/// Cx namespace wrapper.
public struct CxCollectionViewWrapper {
    let collectionView: UICollectionView
}

extension UICollectionView {
    public var cx: CxCollectionViewWrapper { CxCollectionViewWrapper(collectionView: self) }
}

extension CxCollectionViewWrapper {
    /// Returns a function: bind a Publisher<[Section], Never> and get back an AnyCancellable.
    public func items<Section: SectionModelType>(
        dataSource: CxCollectionViewSectionedReloadDataSource<Section>
    ) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        fatalError("stub")
    }

    public func items<Section: AnimatableSectionModelType>(
        dataSource: CxCollectionViewSectionedAnimatedDataSource<Section>
    ) -> (AnyPublisher<[Section], Never>) -> AnyCancellable {
        fatalError("stub")
    }
}
#endif
