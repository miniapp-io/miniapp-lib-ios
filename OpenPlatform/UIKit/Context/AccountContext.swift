import Foundation
import UIKit

internal protocol AccountContext: AnyObject {
    var appName: String  {get}
    var resourceProvider: IResourceProvider {get}
    var mainWindow: Window1? { get }
    var mePaths: [String] { get }
}

