//
//  OptionalTests.swift
//  Tests
//
//  Created by Ryo Aoyama on 3/26/16.
//  Copyright © 2016 Ryo Aoyama. All rights reserved.
//

import XCTest
import Alembic

class OptionalTests: XCTestCase {
    func testOptional() {
        do {
            let data = TestJSON.Optional.data
            let j = try JSON(data: data)
            
            let string: String? = try j <|? "string"
            let int: Int? = try j <|? "int"
            let double: Double? = try j <|? "double"
            let float: Float? = try j <|? "float"
            let bool: Bool? = try j <|? "bool"
            let array: [String]? = try j <|? "array"
            let dictionary: [String: Int]? = try j <|? "dictionary"
            let nestedValue: Int? = try j <|? ["nested", "array", 2]
            let nestedArray: [Int]? = try j <|? ["nested", "array"]
            
            XCTAssertEqual(string, "Alembic")
            XCTAssertEqual(int, 777)
            XCTAssertNil(double)
            XCTAssertEqual(float, 77.7)
            XCTAssertNil(bool)
            XCTAssertNotNil(array)
            XCTAssertNotNil(dictionary)
            XCTAssertNil(nestedValue)
            XCTAssertNil(nestedArray)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalError() {
        do {
            let object = TestJSON.Optional.object
            let j = JSON(object)
            
            _ = try (j <|? "int").to(String?)
            
            XCTFail("Expect the error to occur")
        } catch let DistilError.TypeMismatch(expected: expected, actual: actual) {
            XCTAssert(expected == String?.self)
            XCTAssertEqual(actual as? Int, 777)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalMapping() {
        do {
            let object = TestJSON.Optional.object
            let j = JSON(object)
            
            let user: User? = try j <|? "user1"
            
            XCTAssert(user == nil)
        } catch let e {
            XCTFail("\(e)")
        }
    }
    
    func testOptionalMappingError() {
        do {
            let object = TestJSON.Optional.object
            let j = JSON(object)
            
            _ = try (j <|? "user2").to(User?)
            
            XCTFail("Expected the error to occur")
        } catch let e {
            switch e {
            case let DistilError.MissingPath(path):
                XCTAssert(path == ["user2", "contact", "email"])
            default:
                XCTFail("\(e)")
            }
        }
    }
}

private class User: Distillable {
    let id: Int
    let name: String
    let email: String
    
    required init(json j: JSON) throws {
        try (
            id = j <| "id",
            name = j <| "name",
            email = j <| ["contact", "email"]
        )
    }
    
    private static func distil(j: JSON) throws -> Self {
        return try self.init(json: j)
    }
}