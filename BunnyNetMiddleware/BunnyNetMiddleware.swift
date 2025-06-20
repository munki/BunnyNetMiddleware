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

let BUNDLE_ID = "ManagedInstalls"

/// read a preference
func pref(_ prefName: String, domain: String = BUNDLE_ID) -> Any? {
    return CFPreferencesCopyAppValue(prefName as CFString, domain as CFString)
}

/// return our BunnyNet key
func getBunnyNetKey() -> String? {
    // first try our new preferred location
    if let securityKey = pref("BunnyNetKey") as? String {
        return securityKey
    }
    // attempt to read and return the value as stored for the Python
    // implementation of this middleware
    return CFPreferencesCopyValue(
        "bunny_key" as CFString,
        "ManagedInstallsProc" as CFString,
        kCFPreferencesCurrentUser, // current user, which should be root
        kCFPreferencesAnyHost // IOW, _not_ the ByHost preference
    ) as? String
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
    print("'\(path)' generates '\(tokenFormatted)'")
    return tokenFormatted
}

/// Generates a bunny.net URL
func generateBunnyNetURL(url: String, key: String, expires: Int) -> String? {
    guard var components = URLComponents(string: url) else {
        print("ERROR: Can't parse \(url) as a valid URL")
        return nil
    }
    let token = generateToken(key: key, path: components.path, expires: expires)
    let queryItems: [URLQueryItem] = [
        URLQueryItem(name: "token", value: token),
        URLQueryItem(name: "expires", value: String(expires)),
    ]
    components.queryItems = queryItems
    guard let modifiedURL = components.string else {
        print("ERROR: Can't construct modified URL")
        return nil
    }
    return modifiedURL
}

class BunnyNetMiddleware: MunkiMiddleware {
    /// process the request
    func processRequest(_ request: MunkiMiddlewareRequest) -> MunkiMiddlewareRequest {
        if request.url.contains("cdn.net") {
            guard let securityKey = getBunnyNetKey() else {
                print("ERROR: BunnyNetKey preference not set")
                return request
            }
            let expires = Int(Date().timeIntervalSince1970 + 3600)
            guard let modifiedURL = generateBunnyNetURL(
                url: request.url,
                key: securityKey,
                expires: expires
            ) else {
                // error message was printed by generateBunnyNetURL
                // return unmodifed request
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
