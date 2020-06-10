//
//  BinanceWSErrorTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class BinanceWSErrorTests: XCTestCase {

    func testDecoder_UnknownProperty() {
        let jsonString =
        """
        {"error": {"code": 0, "msg": "Unknown property"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .unknownProperty(message: "Unknown property"))
    }
    
    func testDecoder_InvalidValue() {
        let jsonString =
        """
        {"error": {"code": 1, "msg": "Invalid value type: expected Boolean"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .invalidValue(message: "Invalid value type: expected Boolean"))
    }
    
    func testDecoder_InvalidRequest1() {
        let jsonString =
        """
        {"error": {"code": 2, "msg": "Invalid request: property name must be a string"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .invalidRequest(message: "Invalid request: property name must be a string"))
    }
    
    func testDecoder_InvalidRequest2() {
        let jsonString =
        """
        {"error": {"code": 2, "msg": "Invalid request: request ID must be an unsigned integer"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .invalidRequest(message: "Invalid request: request ID must be an unsigned integer"))
    }
    
    func testDecoder_InvalidRequest3() {
        let jsonString =
        """
        {"error": {"code": 2, "msg": "Invalid request: unknown variant"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .invalidRequest(message: "Invalid request: unknown variant"))
    }
    
    func testDecoder_InvalidRequest4() {
        let jsonString =
        """
        {"error": {"code": 2, "msg": "Invalid request: too many parameters"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .invalidRequest(message: "Invalid request: too many parameters"))
    }
    
    func testDecoder_InvalidRequest5() {
        let jsonString =
        """
        {"error": {"code": 2, "msg": "Invalid request: missing field method at line 1 column 73"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .invalidRequest(message: "Invalid request: missing field method at line 1 column 73"))
    }
    
    func testDecoder_InvalidJSON() {
        let jsonString =
        """
        {"error": {"code":3,"msg":"Invalid JSON: expected value at line %s column %s"} }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceWSError.self, from: jsonData)
        
        XCTAssertEqual(sut, .invalidJSON(message: "Invalid JSON: expected value at line %s column %s"))
    }
}
