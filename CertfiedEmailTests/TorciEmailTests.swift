//
//  CertfiedEmailTests.swift
//  CertfiedEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//

import XCTest
@testable import CertfiedEmail

final class CertfiedEmailTests: XCTestCase {

    static var allSuites: XCTestSuite {
        let suite = XCTestSuite(name: "CertfiedEmail - All Tests")

        suite.addTest(XCTestSuite(forTestCaseClass: ValidEmailTests.self))
        suite.addTest(XCTestSuite(forTestCaseClass: CanSendTests.self))
        suite.addTest(XCTestSuite(forTestCaseClass: CreateDraftBaseTests.self))
        suite.addTest(XCTestSuite(forTestCaseClass: CreateDraftRecipientTests.self))
        suite.addTest(XCTestSuite(forTestCaseClass: CreateDraftCarbonCopyTests.self))
        suite.addTest(XCTestSuite(forTestCaseClass: CreateDraftOptionsTests.self))
        suite.addTest(XCTestSuite(forTestCaseClass: JSONIntegrationTests.self))
        
        return suite
    }
}
