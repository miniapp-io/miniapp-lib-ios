import Foundation
import UIKit

internal protocol WindowInputAccessoryHeightProvider: AnyObject {
    func getWindowInputAccessoryHeight() -> CGFloat
}
