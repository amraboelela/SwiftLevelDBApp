
import XCTest
@testable import SwiftLevelDBAppTests

XCTMain([
     testCase(MainTests.allTests),
     testCase(RengoClientTests.allTests),
])
