//
//  TUIMobilityTests.swift
//  TUIMobilityTests
//
//  Created by Ben Smith on 20/01/2020.
//  Copyright © 2020 Ben Smith. All rights reserved.
//

import XCTest
@testable import TUIMobility

class TUIMobilityTests: XCTestCase {
    var flightVC: ViewController!

    override func setUp() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc: ViewController = storyboard.instantiateViewController(withIdentifier: "ViewController") as! ViewController
        flightVC = vc
        _ = flightVC.view // To call viewDidLoad
    
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func getTestData() {
        let exp = expectation(description: "Check we get some data")
        let connectionService = ConnectionDataService.init()
        connectionService.getItems { (success, result, errorMessage) in
            self.flightVC.connections = result
            exp.fulfill()
        }
    }

    func testInvalidURL() {
        // other setup
        let exp = expectation(description: "Check we get some data")
        var error: UrlConnectionError!
        var connections: [Connection] = []
        var successful: Bool = false
        
        let connectionService = ConnectionDataService.init(connectionsURL: "wwgle.com")
        connectionService.getItems { (success, result, errorMessage) in
            exp.fulfill()
            error = errorMessage
            connections = result
            successful = success
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssertTrue(connections.isEmpty)
            XCTAssert(successful == false, "\(error?.localizedDescription ?? "")")
            
        }
    }
    
    func testValidURLNoJSon() {
        // other setup
        let exp = expectation(description: "Check we get some data")
        var error: UrlConnectionError!
        var connections: [Connection] = []
        var successful: Bool = false

        let connectionService = ConnectionDataService.init(connectionsURL: "https://www.bbc.com")
        connectionService.getItems { (success, result, errorMessage) in
            exp.fulfill()
            error = errorMessage
            connections = result
            successful = success
        }
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssertTrue(connections.isEmpty)
            XCTAssert(error?.localizedDescription == "Data is empty", "\(error?.localizedDescription ?? "")")
            
        }
        
    }
    
    func testWeGetData() {
        // other setup
        getTestData()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssertEqual(self.flightVC.connections.count > 0, true)
        }
    }
    
    func testFilterForDeparturesFromLondon() {
        getTestData()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            self.flightVC.filter(textfieldType: .from, searchText: "London")
            XCTAssertEqual(self.flightVC.departureResults.count == 1, true)
        }


    }

    func testFilterForDestiniationsFromLondon() {
        getTestData()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            self.flightVC.filter(textfieldType: .from, searchText: "London")
            XCTAssertEqual(self.flightVC.destinationResults.count == 3, true)
        }
    }
    
    func testToCheckRouteIsCleared() {
        getTestData()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            ///if
            self.flightVC.filter(textfieldType: .from, searchText: "London")
            self.flightVC.toSearchTextfield.text = self.flightVC.destinationResults[0].to
            
            ///when
            self.flightVC.clearRoute()
            
            //then
            XCTAssertEqual(self.flightVC.destinationResults.count == 0
                && self.flightVC.destinationResults.count == 0
                && self.flightVC.departureResults.count == 0
                && self.flightVC.destinationResults.count == 0
                && self.flightVC.priceLabel?.text == "£"
                && self.flightVC.toSearchTextfield?.text == "", true)
        }
    }
    
    func testToCheckPriceFromLondonToPortoIsCorrect() {
        getTestData()
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            self.flightVC.filter(textfieldType: .from, searchText: "London")
            self.flightVC.filter(textfieldType: .to, searchText: "Porto")
            
            for flight in self.flightVC.destinationResults {
                if flight.to == "Porto" {
                    self.flightVC.sendPrice(price: flight.price)
                    self.flightVC.priceLabel.text = "£\(flight.price)"
                }
            }
            XCTAssertEqual(self.flightVC.priceLabel.text == "£50", true)
        }
    }
    

}
