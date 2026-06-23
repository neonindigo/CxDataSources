# CxDataSources

Combine-native sectioned data sources for `UITableView` and `UICollectionView`, built on top of the [Differentiator](https://github.com/RxSwiftCommunity/RxDataSources) diff engine. Part of the [Cx](https://github.com/neonindigo/Cx) ecosystem.

A direct equivalent of [RxDataSources](https://github.com/RxSwiftCommunity/RxDataSources) with RxSwift replaced by Combine.

## Features

- **Reload data sources** — `CxTableViewSectionedReloadDataSource`, `CxCollectionViewSectionedReloadDataSource`
- **Animated data sources** — `CxTableViewSectionedAnimatedDataSource`, `CxCollectionViewSectionedAnimatedDataSource` (3-phase diff via `Differentiator`)
- **Combine binding** — `tableView.cx.items(dataSource:)` returns `AnyCancellable`
- **Protocols** — `SectionModelType`, `AnimatableSectionModelType`, `IdentifiableType` (re-exported from `Differentiator`)

## Swift Package Manager

```swift
.package(url: "https://github.com/neonindigo/CxDataSources", from: "1.0.0")
```

```swift
.target(name: "MyTarget", dependencies: [
    .product(name: "CxDataSources", package: "CxDataSources"),
])
```

## Usage

```swift
import CxDataSources

// 1. Define your section type
struct MySection: AnimatableSectionModelType {
    typealias Item = MyItem
    typealias Identity = String
    var header: String
    var items: [MyItem]
    var identity: String { header }
    init(original: MySection, items: [MyItem]) { self = original; self.items = items }
}

struct MyItem: IdentifiableType, Equatable {
    typealias Identity = Int
    let id: Int; var title: String
    var identity: Int { id }
}

// 2. Create the data source
let dataSource = CxTableViewSectionedAnimatedDataSource<MySection>(
    configureCell: { ds, tableView, indexPath, item in
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = item.title
        return cell
    }
)

// 3. Bind
var cancellable = viewModel.sections    // AnyPublisher<[MySection], Never>
    .bind(to: tableView.cx.items(dataSource: dataSource))
```

## RxDataSources → CxDataSources

| RxDataSources | CxDataSources |
|---|---|
| `RxTableViewSectionedReloadDataSource` | `CxTableViewSectionedReloadDataSource` |
| `RxTableViewSectionedAnimatedDataSource` | `CxTableViewSectionedAnimatedDataSource` |
| `RxCollectionViewSectionedReloadDataSource` | `CxCollectionViewSectionedReloadDataSource` |
| `RxCollectionViewSectionedAnimatedDataSource` | `CxCollectionViewSectionedAnimatedDataSource` |
| `tableView.rx.items(dataSource:)` | `tableView.cx.items(dataSource:)` |
| `collectionView.rx.items(dataSource:)` | `collectionView.cx.items(dataSource:)` |
| `.disposed(by: disposeBag)` | `.store(in: &cancellables)` |

## Dependencies

- [Differentiator](https://github.com/RxSwiftCommunity/RxDataSources) — the diff engine (zero external deps)
- [Cx](https://github.com/neonindigo/Cx) — Combine utilities (optional; used for `CxCocoa` integration only)
