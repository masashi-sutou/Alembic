import XCTest
@testable import Alembic

class TransformTest: XCTestCase {
    fileprivate struct Error: Swift.Error {}
    
    let object = transformTestJson
    
    func testTransform() {
        let json = JSON(object)
        
        do {
            let map: String = try *json.decode("key")
                .map { "map_" + $0 }
            let flatMap: String = try *json.decode(["nested", "nested_key"])
                .flatMap { v in json.decode("key").map { "flatMap_" + $0 + "_with_" + v } }
            let flatMapOptional: String = try *json.decode(["nested", "nested_key"], as: String.self)
                .flatMap { $0 as String? }
            let flatMapError: String = try *json.decode("missing_key")
                .flatMapError { _ in Decoded.value("flat_map_error") }
            let catchUp: String = *json.decode("error")
                .catch("catch_return")
            
            XCTAssertEqual(map, "map_value")
            XCTAssertEqual(flatMap, "flatMap_value_with_nested_value")
            XCTAssertEqual(flatMapOptional, "nested_value")
            XCTAssertEqual(flatMapError, "flat_map_error")
            XCTAssertEqual(catchUp, "catch_return")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decode("key", as: String.self).flatMap { _ in nil } as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decode("key").filter { $0 == "error" } as String
            
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertEqual(value as? String, "value")
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decodeOption("null").filterNone() as String
        
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type, value) {
            XCTAssertNotNil(type as? String?.Type)
            XCTAssertNotNil(value)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decode("missing_key").mapError { _ in Error() } as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is Error = e {} else { XCTFail("\(e)") }
        }
    }
    
    func testCreateDecoded() {
        let json = JSON(object)
        let value = Decoded.value("value")
        XCTAssertEqual(*value, "value")
        
        do {
            _ = try *ThrowableDecoded<String>.filter
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *ThrowableDecoded<String>.filter
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *ThrowableDecoded<String>.error(Error())
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is Error = e {} else { XCTFail("\(e)") }
        }
        
        do {
            _ = try *json.decode("key", as: String.self).flatMap { _ in ThrowableDecoded.filter } as String
            
            XCTFail("Expect the error to occur")
        } catch let DecodeError.filteredValue(type: type, value: value) {
            XCTAssertNotNil(type as? String.Type)
            XCTAssertNotNil(value as? Void)
        } catch let e {
            XCTFail("\(e)")
        }
        
        do {
            _ = try *json.decode("missing_key").flatMapError { _ in ThrowableDecoded.error(Error()) } as String
            
            XCTFail("Expect the error to occur")
        } catch let e {
            if case is Error = e {} else {
                XCTFail("\(e)")
            }
        }
    }
}

#if os(Linux)
extension TransformTest {
    static var allTests: [(String, (TransformTest) -> () throws -> Void)] {
        return [
            ("testTransform", testTransform),
            ("testCreateDistillate", testCreateDistillate),
        ]
    }
}
#endif
