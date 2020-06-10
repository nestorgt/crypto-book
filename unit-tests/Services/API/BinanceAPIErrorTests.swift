//
//  BinanceAPIErrorTests.swift
//  unit-tests
//
//  Created by Nestor Garcia on 09/06/2020.
//  Copyright © 2020 nestor. All rights reserved.
//

import XCTest
@testable import crypto_book

final class BinanceAPIErrorTests: XCTestCase {

    func testDecoder_General() {
        let jsonString =
        """
        { "code":-1000, "msg":"An unknown error occured while processing the request." }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceAPIError.self, from: jsonData)
        
        XCTAssertEqual(sut, BinanceAPIError.general(message: "An unknown error occured while processing the request."))
    }
    
    func testDecoder_Request() {
        let jsonString =
        """
        { "code":-1121, "msg":"Invalid symbol." }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceAPIError.self, from: jsonData)
        
        XCTAssertEqual(sut, BinanceAPIError.request(message: "Invalid symbol."))
    }
    
    func testDecoder_SAPI() {
        let jsonString =
        """
        { "code":-3021, "msg":"Margin account are not allowed to trade this trading pair." }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceAPIError.self, from: jsonData)
        
        XCTAssertEqual(sut, BinanceAPIError.sapi(message: "Margin account are not allowed to trade this trading pair."))
    }
    
    func testDecoder_Saving() {
        let jsonString =
        """
        { "code":-6001, "msg":"Daily product not exists." }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceAPIError.self, from: jsonData)
        
        XCTAssertEqual(sut, BinanceAPIError.saving(message: "Daily product not exists."))
    }
    
    func testDecoder_Filter() {
        let jsonString =
        """
        { "code":-9000, "msg":"Filter failure: PRICE_FILTER" }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceAPIError.self, from: jsonData)
        
        XCTAssertEqual(sut, BinanceAPIError.filter(message: "Filter failure: PRICE_FILTER"))
    }

    func testDecoder_Other() {
        let jsonString =
        """
        { "code":1010, "msg":"1010_ERROR_MSG_RECEIVED" }
        """
        let jsonData = Parser.JSONData(from: jsonString)!
        let sut = try! JSONDecoder().decode(BinanceAPIError.self, from: jsonData)
        
        XCTAssertEqual(sut, BinanceAPIError.other(code: 1010, message: "1010_ERROR_MSG_RECEIVED"))
    }
}
