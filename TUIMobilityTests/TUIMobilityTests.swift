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
    
        let exp = expectation(description: "Check we get some data")
        ConnectionDataService.getItems { (success, result) in
            self.flightVC.connections = result
            exp.fulfill()
        }
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testWeGetData() {
        // other setup
        
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            XCTAssertEqual(self.flightVC.connections.count > 0, true)
        }
    }
    
    func testFilterForDeparturesFromLondon() {

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            self.flightVC.filter(textfieldType: .from, searchText: "London")
            XCTAssertEqual(self.flightVC.fromSearchTextfield.departureResults.count == 1, true)
        }


    }

    func testFilterForDestiniationsFromLondon() {

        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            self.flightVC.filter(textfieldType: .from, searchText: "London")
            XCTAssertEqual(self.flightVC.toSearchTextfield.destinationResults.count == 3, true)
        }
    }
    
    func testToCheckRouteIsCleared() {
        waitForExpectations(timeout: 10) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
            self.flightVC.filter(textfieldType: .from, searchText: "London")
            self.flightVC.toSearchTextfield.text = self.flightVC.destinationResults[0].to
            self.flightVC.clearRoute()
            XCTAssertEqual(self.flightVC.toSearchTextfield.destinationResults.count == 0
                && self.flightVC.toSearchTextfield.departureResults.count == 0
                && self.flightVC.departureResults.count == 0
                && self.flightVC.destinationResults.count == 0
                && self.flightVC.priceLabel?.text == "£"
                && self.flightVC.toSearchTextfield?.text == "", true)
        }
    }
    
    func testToCheckPriceFromLondonToPortoIsCorrect() {
        
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
