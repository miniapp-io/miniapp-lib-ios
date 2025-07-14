import Foundation

internal protocol ListViewAccessoryItem {
    func isEqualToItem(_ other: ListViewAccessoryItem) -> Bool
    func node(synchronous: Bool) -> ListViewAccessoryItemNode
}
