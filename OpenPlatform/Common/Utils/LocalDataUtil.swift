//
//  LocalDataUtil.swift
//  MiniAppX
//
//  Created by w3bili on 2024/8/29.
//

import Foundation
import LocalAuthentication

func saveCodableData(_ state: Codable?, forKey key: String) {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Failed to access document directory.")
        return
    }

    let fileURL = documentDirectory.appendingPathComponent("\(key).json")
    
    guard let state else {
        do {
            try fileManager.removeItem(at: fileURL)
        }
        catch {
            print("Failed to save codable state for key '\(key)': \(error)")
        }
        return
    }
    
    do {
        let encoder = JSONEncoder()
        let data = try encoder.encode(state)
        try data.write(to: fileURL)
        print("Codable state for key '\(key)' saved successfully.")
    } catch {
        print("Failed to save codable state for key '\(key)': \(error)")
    }
}

// Load data from local file
func loadCodableData<T>(forKey key: String) -> T? where T : Decodable {
    let fileManager = FileManager.default
    guard let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
        print("Failed to access document directory.")
        return nil
    }

    let fileURL = documentDirectory.appendingPathComponent("\(key).json")
    
    do {
        let data = try Data(contentsOf: fileURL)
        let decoder = JSONDecoder()
        let state = try decoder.decode(T.self, from: data)
        return state
    } catch {
        print("Failed to load codable state for key '\(key)': \(error)")
        return nil
    }
}
