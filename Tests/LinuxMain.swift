#if os(Linux)

import XCTest
@testable import AlembicTests

XCTMain([
    testCase(JSONTest.allTests),
    testCase(ValueTest.allTests),
    testCase(OptionTest.allTests),
    testCase(ParseTest.allTests),
    testCase(ParserTest.allTests),
    testCase(ThrowParserTest.allTests),
    testCase(PathTest.allTests),
    testCase(ErrorTest.allTests)
])

#endif
