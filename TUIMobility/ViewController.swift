//
//  ViewController.swift
//  TUIMobility
//
//  Created by Ben Smith on 20/01/2020.
//  Copyright © 2020 Ben Smith. All rights reserved.
//

import UIKit
import CoreLocation

protocol filterSearch: class {
    func filter(textfieldType: SearchTextField, searchText: String)
    func sendPrice(price: Int)
    func clearRoute()
    func calculateRoute(for connection: Connection)
    func clearMap()
}

class ViewController: UIViewController {
    @IBOutlet weak var routeMap: RouteFlight!
    @IBOutlet weak var priceLabel: UILabel!

    @IBOutlet weak var fromSearchTextfield: CustomSearchTextField!
    @IBOutlet weak var toSearchTextfield: CustomSearchTextField!

    var connections: [Connection] = [Connection]()
    var departureResults: [Connection] = [Connection]()
    var destinationResults: [Connection] = [Connection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do {
            let connectionService = ConnectionDataService.init()
            connectionService.getItems { (status, connections, errorMessage) in
                if status {
                    self.connections = connections
                    self.fromSearchTextfield.filterDelegate = self
                    self.toSearchTextfield.filterDelegate = self
                } else {
                    print("failed to get connections")

                }
                
            }
        } catch {
            print("failed to get connections")

        }

    }

}

extension ViewController: filterSearch {
    func filter(textfieldType: SearchTextField, searchText: String) {
        switch textfieldType {
        case SearchTextField.from: // filter departure
            self.departureResults = connections.filter{ ($0.from.range(of: searchText, options: .caseInsensitive) != nil) }
            self.destinationResults = connections.filter{ ($0.from.range(of: searchText, options: .caseInsensitive) != nil) }
            
            //remove duplicates from departure
            self.departureResults = self.departureResults.unique { $0.from }
            
            fromSearchTextfield?.updateRoutingArrays(departureResults: self.departureResults)
            toSearchTextfield?.updateRoutingArrays(destinationResults: self.destinationResults)

        case SearchTextField.to:
            //filter destination text field
            toSearchTextfield?.updateRoutingArrays(destinationResults: self.destinationResults.filter{ ($0.to.range(of: searchText, options: .caseInsensitive) != nil) })
        }
    }
    func sendPrice(price: Int) {
        self.priceLabel.text = "£\(price)"
    }
    
    func calculateRoute(for connection: Connection) {
        self.clearMap()
        self.routeMap.route(flightConnection: connection)
    }
    
    func clearRoute() {
        self.destinationResults = []
        self.departureResults = []
        self.toSearchTextfield.updateRoutingArrays(destinationResults: [], departureResults: [])
        self.fromSearchTextfield.updateRoutingArrays(destinationResults: [], departureResults: [])
        toSearchTextfield?.text = ""
        self.priceLabel.text = "£"
        self.clearMap()
    }
    
    func clearMap() {
        DispatchQueue.main.async {
            self.routeMap.flightRoute.removeOverlays(self.routeMap.flightRoute.overlays)
            self.routeMap.flightRoute.removeAnnotations(self.routeMap.flightRoute.annotations)

        }
    }
}
