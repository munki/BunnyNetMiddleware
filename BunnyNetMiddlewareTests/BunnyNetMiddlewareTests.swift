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
    @Test func generateTokenWithNoPercentEncodingInPathGeneratesExpected() {
        let token = generateToken(
            key: "FOOBARBAZ",
            path: "/someinstaller.dmg",
            expires: 1_747_270_308
        )
        #expect(token == "CNje5yxtqEdjkrN4RvhSlg")
    }

    @Test func generateTokenWithPercentEncodedPathGeneratesExpected() {
        let token = generateToken(
            key: "FOOBARBAZ",
            path: "/some%20installer.dmg",
            expires: 1_747_270_308
        )
        #expect(token == "IGdIFRU7caWJqfLIRmbwxw")
    }

    @Test func urlWithNoPercentEncodingGeneratesExpectedBunnyNetURL() {
        let testURL = "https://test.b-cdn.net/someinstaller.dmg"
        let expectedURL = "https://test.b-cdn.net/someinstaller.dmg?token=CNje5yxtqEdjkrN4RvhSlg&expires=1747270308"
        let modifiedURL = generateBunnyNetURL(
            url: testURL,
            key: "FOOBARBAZ",
            expires: 1_747_270_308
        )
        #expect(modifiedURL == expectedURL)
    }

    @Test func urlWithPercentEncodingGeneratesExpectedBunnyNetURL2() {
        let testURL = "https://test.b-cdn.net/some%20installer.dmg"
        let expectedURL = "https://test.b-cdn.net/some%20installer.dmg?token=krv82IZ0s4Nhg2zfVtRlfA&expires=1747270308"
        let modifiedURL = generateBunnyNetURL(
            url: testURL,
            key: "FOOBARBAZ",
            expires: 1_747_270_308
        )
        #expect(modifiedURL == expectedURL)
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
