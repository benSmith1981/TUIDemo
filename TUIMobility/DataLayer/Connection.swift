//
//  Connection.swift
//  TUIMobility
//
//  Created by Ben Smith on 20/01/2020.
//  Copyright © 2020 Ben Smith. All rights reserved.
//

import Foundation

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

typealias response =  (Bool,[Connection],UrlConnectionError?) -> Void
var baseURL = "https://raw.githubusercontent.com/TuiMobilityHub/ios-code-challenge/master/connections.json"

enum UrlConnectionError: Error {
    case invalid(String)
    case connectionError(String)
    case dataError(String)
    case decodingError(String)
}

class ConnectionDataService {
    private var connectionsURL: String
    init(connectionsURL: String = baseURL) {
        self.connectionsURL = connectionsURL
    }
    
    func getItems(onCompletion: @escaping response) {
        
        //create the url with NSURL
        guard let url = URL(string: connectionsURL) else {
           onCompletion(false, [], UrlConnectionError.invalid("\(connectionsURL) is not a valid URL"))
           return
        }
        
        //create the session object
        let session = URLSession.shared
        
        //create dataTask using the session object to send data to the server
        let task = session.dataTask(with: url, completionHandler: { data, response, error in

            guard error == nil else {
                onCompletion(false, [], UrlConnectionError.connectionError(error?.localizedDescription ?? ""))
                return
            }
            
            guard let data = data else {
                onCompletion(false, [], UrlConnectionError.dataError("Data is empty"))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let connectionsAll = try decoder.decode(Response.self,
                                                        from: data)
                onCompletion(true, connectionsAll.connections, nil)
                
            } catch {
                onCompletion(false, [], UrlConnectionError.decodingError("Decoding problem with JSON"))
            }
            
        })
        task.resume()
    }

}

