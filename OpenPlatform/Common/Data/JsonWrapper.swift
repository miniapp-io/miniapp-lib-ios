import Foundation

class JSON: ExpressibleByDictionaryLiteral {
    private var storage: [String: Any]
    
    // MARK: - 初始化方法
    required init() {
        self.storage = [:]
    }
    
    init(_ dictionary: [String: Any]) {
        self.storage = dictionary
    }
    
    // 实现 ExpressibleByDictionaryLiteral 协议
    required init(dictionaryLiteral elements: (String, Any)...) {
        self.storage = [:]
        for (key, value) in elements {
            storage[key] = value
        }
    }
    
    // MARK: - 数据操作
    func set<T>(_ value: T, forKey key: String) {
        storage[key] = value
    }
    
    func get<T>(_ key: String) -> T? {
        return storage[key] as? T
    }
    
    func remove(_ key: String) {
        storage.removeValue(forKey: key)
    }
    
    func contains(_ key: String) -> Bool {
        return storage.keys.contains(key)
    }
    
    func clear() {
        storage.removeAll()
    }
    
    var keys: [String] {
        return Array(storage.keys)
    }
    
    var count: Int {
        return storage.count
    }
    
    // MARK: - JSON 转换
    var string: String? {
        return toString()
    }
    
    var data: Data? {
        return toData()
    }
    
    func toString(prettyPrinted: Bool = false) -> String? {
        guard JSONSerialization.isValidJSONObject(storage) else {
            return nil
        }
        
        let options: JSONSerialization.WritingOptions = prettyPrinted ? .prettyPrinted : []
        guard let jsonData = try? JSONSerialization.data(withJSONObject: storage, options: options) else {
            return nil
        }
        
        return String(data: jsonData, encoding: .utf8)
    }
    
    func toData() -> Data? {
        guard JSONSerialization.isValidJSONObject(storage) else {
            return nil
        }
        
        return try? JSONSerialization.data(withJSONObject: storage, options: [])
    }
    
    // MARK: - 静态方法
    static func parse(_ jsonString: String) -> JSON? {
        guard let data = jsonString.data(using: .utf8) else {
            return nil
        }
        
        return parse(data)
    }
    
    static func parse(_ jsonData: Data) -> JSON? {
        do {
            let object = try JSONSerialization.jsonObject(with: jsonData, options: [])
            if let dictionary = object as? [String: Any] {
                return JSON(dictionary)
            }
        } catch {
            print("JSON 解析失败: \(error)")
        }
        return nil
    }
    
    // MARK: - 下标支持
    subscript(key: String) -> Any? {
        get { return storage[key] }
        set { storage[key] = newValue }
    }
    
}
