import Combine
import Differentiator

extension Publisher where Failure == Never {
    /// Binds this publisher to a table view via the given data source.
    /// Store the returned `AnyCancellable` — dropping it cancels the binding immediately.
    public func bind(
        to binding: (Self) -> AnyCancellable
    ) -> AnyCancellable {
        binding(self)
    }
}
