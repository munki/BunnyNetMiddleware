//
//  BunnyNetMiddlewareTests.swift
//  BunnyNetMiddlewareTests
//
//  Created by Greg Neagle on 5/14/25.
//

import Testing

struct BunnyNetMiddlewareTests {
    /// This simply tests that the generateToken function produces the same output
    /// as the Python version
    @Test func generateTokenGeneratesExpected() {
        let token = generateToken(
            key: "FOOBARBAZ",
            path: "/someinstaller.dmg",
            expires: 1_747_270_308
        )
        #expect(token == "CNje5yxtqEdjkrN4RvhSlg")
    }
    
    /// Test that a non-BunnyNet request is returned unmodified
    @Test func nonBunnyNetRequestShouldNotBeModified() async throws {
        let request = MunkiMiddlewareRequest(
            url: "https://example.com",
            headers: [:]
        )
        // currently MunkiMiddlewareRequest structs are not directly comparable, so we''ll just
        // compare the instance variables
        let processedRequest = BunnyNetMiddleware().processRequest(request)
        #expect(processedRequest.url == request.url)
        #expect(processedRequest.headers == request.headers)
    }
}
