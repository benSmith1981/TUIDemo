//
//  Connection.swift
//  TUIMobility
//
//  Created by Ben Smith on 20/01/2020.
//  Copyright © 2020 Ben Smith. All rights reserved.
//

import Foundation
var connectionsURL = "https://raw.githubusercontent.com/TuiMobilityHub/ios-code-challenge/master/connections.json"

struct Response: Codable {
    var connections: [Connection]
}
struct Connection: Codable {
    var coordinates: coordinates
    var from: String
    var price: Int
    var to: String
    
}

struct coordinates: Codable {
    var from: from
    var to: to
}

struct from: Codable {
    var lat: Double
    var long: Double
}
struct to: Codable {
    var lat: Double
    var long: Double
}

typealias response =  (Bool,[Connection]) -> Void

class ConnectionDataService {
    public static func getItems(onCompletion: @escaping response) {
        
        //create the url with NSURL
        guard let url = URL(string: connectionsURL) else {
           return
        }
        
        //create the session object
        let session = URLSession.shared
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: url, completionHandler: { data, response, error in

            guard error == nil else {
                onCompletion(false, [])
                return
            }
            
            guard let data = data else {
                onCompletion(false, [])
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let connectionsAll = try decoder.decode(Response.self,
                                                        from: data)
                onCompletion(true, connectionsAll.connections)
                
            } catch {
                onCompletion(false, [])
            }
            
        })
        task.resume()
    }
    
    public static func getStaticJson(onCompletion: @escaping response) {
        if let path = Bundle.main.path(forResource: "Connections", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                if let jsonResult = jsonResult as? Dictionary<String, AnyObject>,
                    let connections = jsonResult["connections"] as? [Any] {
                    // do stuff
                    let jsonData = try JSONSerialization.data(withJSONObject: connections, options: [])

                    do {
                        let decoder = JSONDecoder()
                        let connectionsAll = try decoder.decode([Connection].self,
                                                             from: jsonData )
                        onCompletion(true, connectionsAll)
                        
                    } catch {
                        onCompletion(false, [])
                    }
                }
            } catch {
                // handle error
                onCompletion(false, [])

            }
        }
    }

}

