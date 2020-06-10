//
//  APIServiceTests.swift
//  integration-tests
//
//  Created by Nestor Garcia on 07/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class APIServiceTests: XCTestCase {

    var apiService: APIServiceProtocol!
    var result: Result<Data, APIError>!
    
    override func setUp() {
        super.setUp()
        apiService = APIService()
    }
    
    // MARK: - Tests
    
    func testRequestSuccess() {
        performAndWait(for: URLRequest(url: URL(string: "https://www.google.com")!),
                       with: XCTestExpectation(description: "Performs a request"))
        
        XCTAssertTrue(result.isSuccess)
    }
    
    func testRequestSuccess_InsecureConnection() {
        performAndWait(for: URLRequest(url: URL(string: "http://www.google.com")!),
                       with: XCTestExpectation(description: "Performs a request"))
        
        XCTAssertTrue(result.isFailure)
    }
    
    func testRequestFailure_NotFound() {
        performAndWait(for: URLRequest(url: URL(string: "https://www.google.com/notfound")!),
                       with: XCTestExpectation(description: "Performs a request"))
        
        XCTAssertEqual(result.error as? APIError, APIError.notFound)
    }
    
    // MARK: - Helpers
    
    private func performAndWait(for urlRequest: URLRequest, with expectation: XCTestExpectation) {
        apiService.perform(urlRequest: urlRequest) { [weak self] result in
            self?.result = result
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 2)
    }
}
