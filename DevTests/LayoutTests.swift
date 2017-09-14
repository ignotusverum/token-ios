//
//  LayoutTests.swift
//  consumer
//
//  Created by Gregory Sapienza on 2/16/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import XCTest

class LayoutTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBasicVerticalLayout() {
        let mainRect = CGRect(x: 0, y: 0, width: 200, height: 150)
        
        let layoutTest1 = LayoutTest()
        let layoutTest2 = LayoutTest()
        let layoutTest3 = LayoutTest()
        
        var verticalLayout = VerticalLayout(contents: [layoutTest1, layoutTest2, layoutTest3], verticalSeperatingSpace: 0)
        verticalLayout.layout(in: mainRect)
        
        XCTAssertEqual(mainRect.height / 3, layoutTest1.rect.height)
    }
    
    func testNestedVerticalLayout() {
        let mainRect = CGRect(x: 0, y: 0, width: 200, height: 150)
        
        let layoutTest1 = LayoutTest()
        let layoutTest2 = LayoutTest()
        let layoutTest3 = LayoutTest()
        
        let nestedVerticalLayout = VerticalLayout(contents: [layoutTest1, layoutTest2, layoutTest3], verticalSeperatingSpace: 0)
        
        let layoutTest4 = LayoutTest()
        
        var mainVerticalLayout = VerticalLayout(contents: [layoutTest4, nestedVerticalLayout], verticalSeperatingSpace: 0)
        mainVerticalLayout.layout(in: mainRect)
        
        XCTAssertEqual(mainRect.height / 2, layoutTest4.rect.height)
        XCTAssertEqual((mainRect.height / 2) / 3, layoutTest3.rect.height)
    }
}
