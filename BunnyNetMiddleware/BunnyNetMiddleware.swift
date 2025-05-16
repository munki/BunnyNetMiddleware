//
//  BunnyNetMiddleware.swift
//  BunnyNet3Middleware
//
//  Created by Greg Neagle on 5/14/25.
//
// Proof-of-concept port of ofirgalcon's bunny.net-middleware
// https://github.com/ofirgalcon/bunny.net-middleware
//
// Differs from the original in that the security key is stored as
// "BunnyNetKey" in the "ManagedInstalls" domain

import CryptoKit
import Foundation

let BUNDLE_ID = "ManagedInstalls" as CFString

/// read a preference
func pref(_ prefName: String) -> Any? {
    return CFPreferencesCopyAppValue(prefName as CFString, BUNDLE_ID)
}

/// Generates a bunny.net token.
/// See https://docs.bunny.net/docs/cdn-token-authentication-basic
func generateToken(key: String, path: String, expires: Int, filteredIP: String = "") -> String {
    let tokenContent = "\(key)\(path)\(expires)\(filteredIP)"
    let tokenDigest = Data(Insecure.MD5.hash(data: Data(tokenContent.utf8)))
    let tokenBase64 = tokenDigest.base64EncodedString()
    let tokenFormatted = tokenBase64
        .replacingOccurrences(of: "\n", with: "")
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
    return tokenFormatted
}

class BunnyNetMiddleware: MunkiMiddleware {
    /// process the request
    func processRequest(_ request: MunkiMiddlewareRequest) -> MunkiMiddlewareRequest {
        if request.url.contains("cdn.net") {
            guard let securityKey = pref("BunnyNetKey") as? String else {
                print("BunnyNetKey preference not set")
                return request
            }
            guard var components = URLComponents(string: request.url) else {
                print("Can't parse \(request.url) as a valid URL")
                return request
            }
            let expires = Int(Date().timeIntervalSince1970 + 3600)
            let token = generateToken(
                key: securityKey,
                path: components.path,
                expires: expires
            )
            let queryItems: [URLQueryItem] = [
                URLQueryItem(name: "token", value: token),
                URLQueryItem(name: "expires", value: String(expires)),
            ]
            components.queryItems = queryItems
            guard let modifiedURL = components.string else {
                print("Can't construct modified URL")
                return request
            }
            var modifiedRequest = request
            modifiedRequest.url = modifiedURL
            return modifiedRequest
        }
        // not a bunny.net URL, just return the unmodified request
        return request
    }
}

// MARK: dylib "interface"

final class BunnyNetMiddlewareBuilder: MiddlewarePluginBuilder {
    override func create() -> MunkiMiddleware {
        return BunnyNetMiddleware()
    }
}

/// Function with C calling style for our dylib.
/// We use it to instantiate the MunkiMiddleware object and return an instance
@_cdecl("createPlugin")
public func createPlugin() -> UnsafeMutableRawPointer {
    return Unmanaged.passRetained(BunnyNetMiddlewareBuilder()).toOpaque()
}
