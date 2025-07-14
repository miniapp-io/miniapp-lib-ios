//
//  ApiError.swift
//  MiniAppX
//
//  Created by w3bili on 2024/7/8.
//

import Foundation

public enum ApiError: Error {
    case waitForSetup
    case authInvalid
    case invalidURL
    case encodingFailed
    case invalidResponse
    case requestFailed(statusCode: Int, message: String?)
    case invalidData
    case decodingFailed
    case invalidParameter(String)
}
