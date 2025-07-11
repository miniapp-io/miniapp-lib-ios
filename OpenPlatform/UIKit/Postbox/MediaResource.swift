import Foundation

internal struct MediaResourceId: Equatable, Hashable {
    public var stringRepresentation: String

    public init(_ stringRepresentation: String) {
        self.stringRepresentation = stringRepresentation
    }
}

internal protocol MediaResource: AnyObject {
    var id: MediaResourceId { get }
    var size: Int64? { get }
    var streamable: Bool { get }
    var headerSize: Int32 { get }
    
    func isEqual(to: MediaResource) -> Bool
}

internal extension MediaResource {
    var streamable: Bool {
        return false
    }
    
    var headerSize: Int32 {
        return 0
    }
}

//public protocol CachedMediaResourceRepresentation {
//    var uniqueId: String { get }
//    var keepDuration: CachedMediaRepresentationKeepDuration { get }
//    func isEqual(to: CachedMediaResourceRepresentation) -> Bool
//}

internal protocol MediaResourceFetchTag {
}

internal protocol MediaResourceFetchInfo {
}

//internal  final class MediaResourceStorageLocation {
//    public let peerId: PeerId
//    public let messageId: MessageId?
//    
//    public init(peerId: PeerId, messageId: MessageId?) {
//        self.peerId = peerId
//        self.messageId = messageId
//    }
//}

//internal struct MediaResourceFetchParameters {
//    public let tag: MediaResourceFetchTag?
//    public let info: MediaResourceFetchInfo?
//    public let location: MediaResourceStorageLocation?
//    public let contentType: UInt8
//    public let isRandomAccessAllowed: Bool
//    
//    public init(tag: MediaResourceFetchTag?, info: MediaResourceFetchInfo?, location: MediaResourceStorageLocation?, contentType: UInt8, isRandomAccessAllowed: Bool) {
//        self.tag = tag
//        self.info = info
//        self.location = location
//        self.contentType = contentType
//        self.isRandomAccessAllowed = isRandomAccessAllowed
//    }
//}
