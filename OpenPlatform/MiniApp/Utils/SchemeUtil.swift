//
//  TonSchemeUtil.swift
//  MiniAppX
//
//  Created by w3bili on 2024/9/14.
//

import Foundation

internal class SchemeUtil {

    private static var uriParse: NSRegularExpression?
    
    private static func getURIParsePattern() -> NSRegularExpression? {
        if uriParse == nil {
            do {
                uriParse = try NSRegularExpression(pattern: "^(([^:/?#]+):)?(//([^/?#]*))?([^?#]*)(\\?([^#]*))?(#(.*))?", options: [])
            } catch {
                print("Error creating regular expression: \(error)")
            }
        }
        return uriParse
    }

    private static func getHostAuthority(_ uri: String?) -> String? {
        guard let uri = uri else { return nil }

        guard let pattern = getURIParsePattern() else { return nil }

        let nsUri = uri as NSString
        let matches = pattern.matches(in: uri, options: [], range: NSRange(location: 0, length: nsUri.length))

        if let match = matches.first, match.numberOfRanges > 4 {
            var authority = nsUri.substring(with: match.range(at: 4)).lowercased()
            return authority
        }

        return nil
    }

    private static func getHostAuthority(_ uri: URL?) -> String? {
        guard let uri = uri else { return nil }
        return getHostAuthority(uri.absoluteString)
    }

    static func isInternalUri(_ uri: URL?, hosts: [String]) -> Bool {
        guard var host = getHostAuthority(uri) else { return false }
        host = host.lowercased()

        return hosts.first { $0.lowercased().contains(host) } != nil
    }
}

internal extension URL {
    var queryParameters: [String: String]? {
        var params = [String: String]()
        let queryItems = URLComponents(string: self.absoluteString)?.queryItems
        queryItems?.forEach { params[$0.name] = $0.value }
        return params
    }
}

