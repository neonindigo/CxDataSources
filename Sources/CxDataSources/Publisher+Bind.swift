import Combine
import Differentiator

extension Publisher where Failure == Never {
    /// Binds this publisher to a table view via the given data source.
    /// Returns the AnyCancellable — store it to keep the binding alive.
    @discardableResult  // intentional: caller may choose to store or let it fire-and-forget
    public func bind(
        to binding: (Self) -> AnyCancellable
    ) -> AnyCancellable {
        binding(self)
    }
}
