import Foundation
import UIKit

internal  final class ListViewTapGestureRecognizer: UITapGestureRecognizer {
    public func cancel() {
        self.state = .failed
    }
}
