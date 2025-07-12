import Foundation

internal enum ValueBoxKeyType: Int32 {
    case binary
    case int64
}

internal struct ValueBoxTable {
    let id: Int32
    let keyType: ValueBoxKeyType
    let compactValuesOnCreation: Bool
    
    public init(id: Int32, keyType: ValueBoxKeyType, compactValuesOnCreation: Bool) {
        self.id = id
        self.keyType = keyType
        self.compactValuesOnCreation = compactValuesOnCreation
    }
}

internal struct ValueBoxFullTextTable {
    let id: Int32
}

internal struct ValueBoxEncryptionParameters {
    internal struct Key {
        public let data: Data
        
        public init?(data: Data) {
            if data.count == 32 {
                self.data = data
            } else {
                return nil
            }
        }
    }
    
    internal struct Salt {
        public let data: Data
        
        public init?(data: Data) {
            if data.count == 16 {
                self.data = data
            } else {
                return nil
            }
        }
    }
    
    public let forceEncryptionIfNoSet: Bool
    public let key: Key
    public let salt: Salt
    
    public init(forceEncryptionIfNoSet: Bool, key: Key, salt: Salt) {
        self.forceEncryptionIfNoSet = forceEncryptionIfNoSet
        self.key = key
        self.salt = salt
    }
}

internal enum ValueBoxFilterResult {
    case accept
    case skip
    case stop
}

internal protocol ValueBox {
    func begin()
    func commit()
    func checkpoint()
    
    func beginStats()
    func endStats()
    
    func range(_ table: ValueBoxTable, start: ValueBoxKey, end: ValueBoxKey, values: (ValueBoxKey, ReadBuffer) -> Bool, limit: Int)
    func filteredRange(_ table: ValueBoxTable, start: ValueBoxKey, end: ValueBoxKey, values: (ValueBoxKey, ReadBuffer) -> ValueBoxFilterResult, limit: Int)
    func filteredRange(_ table: ValueBoxTable, start: ValueBoxKey, end: ValueBoxKey, keys: (ValueBoxKey) -> ValueBoxFilterResult, limit: Int)
    func range(_ table: ValueBoxTable, start: ValueBoxKey, end: ValueBoxKey, keys: (ValueBoxKey) -> Bool, limit: Int)
    func scan(_ table: ValueBoxTable, values: (ValueBoxKey, ReadBuffer) -> Bool)
    func scan(_ table: ValueBoxTable, keys: (ValueBoxKey) -> Bool)
    func scanInt64(_ table: ValueBoxTable, values: (Int64, ReadBuffer) -> Bool)
    func scanInt64(_ table: ValueBoxTable, keys: (Int64) -> Bool)
    func get(_ table: ValueBoxTable, key: ValueBoxKey) -> ReadBuffer?
    func read(_ table: ValueBoxTable, key: ValueBoxKey, _ process: (Int, (UnsafeMutableRawPointer, Int, Int) -> Void) -> Void)
    func readWrite(_ table: ValueBoxTable, key: ValueBoxKey, _ process: (Int, (UnsafeMutableRawPointer, Int, Int) -> Void, (UnsafeRawPointer, Int, Int) -> Void) -> Void)
    func exists(_ table: ValueBoxTable, key: ValueBoxKey) -> Bool
    func set(_ table: ValueBoxTable, key: ValueBoxKey, value: MemoryBuffer)
    func remove(_ table: ValueBoxTable, key: ValueBoxKey, secure: Bool)
    func move(_ table: ValueBoxTable, from previousKey: ValueBoxKey, to updatedKey: ValueBoxKey)
    func copy(fromTable: ValueBoxTable, fromKey: ValueBoxKey, toTable: ValueBoxTable, toKey: ValueBoxKey)
    func removeRange(_ table: ValueBoxTable, start: ValueBoxKey, end: ValueBoxKey)
    func fullTextSet(_ table: ValueBoxFullTextTable, collectionId: String, itemId: String, contents: String, tags: String)
    func fullTextMatch(_ table: ValueBoxFullTextTable, collectionId: String?, query: String, tags: String?, values: (String, String) -> Bool)
    func fullTextRemove(_ table: ValueBoxFullTextTable, itemId: String, secure: Bool)
    func removeAllFromTable(_ table: ValueBoxTable)
    func removeTable(_ table: ValueBoxTable)
    func renameTable(_ table: ValueBoxTable, to toTable: ValueBoxTable)
    func drop()
    func count(_ table: ValueBoxTable, start: ValueBoxKey, end: ValueBoxKey) -> Int
    func count(_ table: ValueBoxTable) -> Int
    
    func exportEncrypted(to exportBasePath: String, encryptionParameters: ValueBoxEncryptionParameters)
}
