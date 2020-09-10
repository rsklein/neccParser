//
//  neccParserTests.swift
//  neccParserTests
//
//  Created by RSK on 9/9/20.
//  Copyright © 2020 Roy Klein. All rights reserved.
//

import XCTest
@testable import neccParser


class neccParserTests: XCTestCase {
    var sut: Find!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        super.setUp()
        sut = Find()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        sut = nil
        super.tearDown()

    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }

    func testQuietMode() {
        let quietMode = sut.quiet
        XCTAssertEqual(quietMode, false, "quietMode not set correctly")
    }

}
