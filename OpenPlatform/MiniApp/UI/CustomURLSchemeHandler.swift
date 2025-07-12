//
//  CustomURLSchemeHandler.swift
//  MiniAppX
//
//  Created by w3bili on 2024/9/6.
//

import WebKit
import Foundation

internal class CustomURLSchemeHandler: NSObject, WKURLSchemeHandler {
    
    func webView(_ webView: WKWebView, start urlSchemeTask: WKURLSchemeTask) {
        guard let requestURL = urlSchemeTask.request.url?.absoluteString.lowercased() else {
            // Invalid URL, report error
             let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadURL, userInfo: nil)
             urlSchemeTask.didFailWithError(error)
            return
        }
        
        // Check if the URL is the one to be intercepted
        if requestURL == "https://raw.githubusercontent.com/ton-blockchain/wallets-list/main/wallets-v2.json" {
            let newURL = "https://s.openweb3.io/tonbridge/wallets-v2.json"
            guard let newRequestURL = URL(string: newURL) else {
                urlSchemeTask.didFailWithError(NSError(domain: "Invalid URL", code: 400, userInfo: nil))
                return
            }
            
            // Use URLSession to send new request
            var newRequest = URLRequest(url: newRequestURL)
            newRequest.httpMethod = "GET"
            
            let session = URLSession.shared
            let task = session.dataTask(with: newRequest) { (data, response, error) in
                if let error = error {
                    print("Error fetching data: \(error)")
                    urlSchemeTask.didFailWithError(error)
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse, let data = data else {
                    urlSchemeTask.didFailWithError(NSError(domain: "Invalid response", code: 500, userInfo: nil))
                    return
                }
                
                // Create custom response
                let mimeType = httpResponse.mimeType ?? "text/plain"
                let encoding = httpResponse.textEncodingName ?? "utf-8"
                
                let headers = httpResponse.allHeaderFields as? [String: String] ?? [:]
                var responseHeaders = headers
                responseHeaders["Access-Control-Allow-Origin"] = "*"
                responseHeaders["cross-origin-resource-policy"] = "cross-origin"
                
                let response = URLResponse(
                    url: newRequestURL,
                    mimeType: mimeType,
                    expectedContentLength: data.count,
                    textEncodingName: encoding
                )
                
                let httpResponseData = HTTPURLResponse(url: newRequestURL, statusCode: httpResponse.statusCode, httpVersion: nil, headerFields: responseHeaders)
                
                urlSchemeTask.didReceive(httpResponseData!)
                urlSchemeTask.didReceive(data)
                urlSchemeTask.didFinish()
            }
            
            task.resume()
        } else {
            // For non-intercepted requests, manually load and return data
            let session = URLSession.shared
            var newRequest = URLRequest(url: URL(string: requestURL)!)
            let task = session.dataTask(with: newRequest) { data, response, error in
                if let error = error {
                    urlSchemeTask.didFailWithError(error)
                } else if let response = response, let data = data {
                    urlSchemeTask.didReceive(response)
                    urlSchemeTask.didReceive(data)
                    urlSchemeTask.didFinish()
                }
            }
            task.resume()
        }
    }
    
    func webView(_ webView: WKWebView, stop urlSchemeTask: WKURLSchemeTask) {
        // Here you can handle the logic for stopping tasks
    }
}

