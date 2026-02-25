//
//  ValidEmailTests.swift
//  TorciEmail
//
//  Created by Adolfo Torcicollo on 23/02/26.
//


import XCTest
@testable import TorciEmail

final class ValidEmailTests: XCTestCase {

    var viewModel: ComposeMailViewModel!

    override func setUp() {
        super.setUp()
        viewModel = ComposeMailViewModel(fromEmail: "torci.ado@outlook.it")
    }

    override func tearDown() {
        viewModel = nil
        super.tearDown()
    }

    func test_isValidEmail_true_withValidEmail() {
        XCTAssertTrue(viewModel.isValidEmail("torci.ado@outlook.it"))
    }

    func test_isValidEmail_false_withNoAtSign() {
        XCTAssertFalse(viewModel.isValidEmail("emailnonvalida"))
    }

    func test_isValidEmail_false_withNoDomain() {
        XCTAssertFalse(viewModel.isValidEmail("torci@"))
    }

    func test_isValidEmail_false_withSpaces() {
        XCTAssertFalse(viewModel.isValidEmail("torci .ado@outlook.it"))
    }

    func test_isValidEmail_false_withEmpty() {
        XCTAssertFalse(viewModel.isValidEmail(""))
    }
}
