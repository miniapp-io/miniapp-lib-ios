import Foundation

internal class LRUSharedPreferencesCache {
    
    private let globalKey = "__open_platform_local_"
    
    private var userDefaults: UserDefaults

    static let shared = LRUSharedPreferencesCache()

    private init() {
        userDefaults = UserDefaults.standard
    }

    func getValue(forKey key: String) -> String? {
        return userDefaults.string(forKey: globalKey+key)
    }

    func saveValue(_ value: String, forKey key: String) {
        userDefaults.set(value, forKey: globalKey+key)
        userDefaults.synchronize()
    }

    private func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: globalKey+key)
        userDefaults.synchronize()
    }
}
