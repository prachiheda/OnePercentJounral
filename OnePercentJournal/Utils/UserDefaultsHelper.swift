//
//  UserDefaultsHelper.swift
//  OnePercentJournal
//
//  Created by Prachi Heda on 2/12/25.
//

import Foundation

class UserDefaultsHelper {
    static func save<T: Codable>(_ object: T, key: String) {
        if let encoded = try? JSONEncoder().encode(object) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    static func load<T: Codable>(_ type: T.Type, key: String) -> T? {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(T.self, from: data) {
            return decoded
        }
        return nil
    }
}

