import Foundation

private var postboxLogger: (String) -> Void = { _ in }
private var postboxLoggerSync: () -> Void = {}

internal func setPostboxLogger(_ f: @escaping (String) -> Void, sync: @escaping () -> Void) {
    postboxLogger = f
    postboxLoggerSync = sync
}

internal func postboxLog(_ what: @autoclosure () -> String) {
    postboxLogger(what())
}

internal func postboxLogSync() {
    postboxLoggerSync()
}
