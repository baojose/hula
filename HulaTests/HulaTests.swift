//
//  HulaTests.swift
//  HulaTests
//
//  Created by Star on 3/8/17.
//  Copyright © 2017 star. All rights reserved.
//

import XCTest
@testable import Hula

class HulaTests: XCTestCase {
    
    func testProductPopulateAcceptsDoubleLocationCoordinates() {
        let product = HulaProduct()
        let payload: NSDictionary = [
            "location": [37.7749295, -122.4194155]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.productLocation.coordinate.latitude, 37.7749295, accuracy: 0.00001)
        XCTAssertEqual(product.productLocation.coordinate.longitude, -122.4194155, accuracy: 0.00001)
    }

    func testProductPopulateFiltersEmptyImageLinks() {
        let product = HulaProduct()
        let payload: NSDictionary = [
            "images": ["front.jpg", "", "side.jpg", ""]
        ]

        product.populate(with: payload)

        XCTAssertEqual(product.arrProductPhotoLink, ["front.jpg", "side.jpg"])
    }
    
}
