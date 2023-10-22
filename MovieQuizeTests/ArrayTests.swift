//
//  ArrayTests.swift
//  MovieQuizeTests
//
//  Created by Глеб Хамин on 16.10.2023.
//

import Foundation
import XCTest
@testable import MovieQuize

class ArrayTests: XCTestCase {
    func testGetValueInRange() throws {
        // Given
        let array = [1,1,2,3,5]
        
        // When
        let value = array[safe: 2]
        
        // Then
        XCTAsserNotNil(value)
        XCTAssertEqual(value, 2)
    }
    
    func testGetValueOutOfRange() throws {
        // Given
        let array = [1,1,2,3,5]
        
        // When
        let value = array[safe: 20]
        
        // Then
        XCTAssertNil(value)
    }
}
