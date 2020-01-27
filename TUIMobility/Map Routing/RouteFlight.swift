//
//  RouteToAirportTableViewCell.swift
//  TUIMobility
//
//  Created by Ben Smith on 20/01/2020.
//  Copyright © 2020 Ben Smith. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Foundation

class RouteFlight: UIView, MKMapViewDelegate, CLLocationManagerDelegate {
    
    @IBOutlet weak var routeToAirport: MKMapView!
    private var fromCoord = CLLocationCoordinate2D()
    private var toCoord = CLLocationCoordinate2D()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.routeToAirport.delegate = self
    }
    
    func route(flightConnection: Connection) {
        fromCoord = CLLocationCoordinate2D(latitude: flightConnection.coordinates.from.lat,
                                           longitude: flightConnection.coordinates.from.long)
        toCoord = CLLocationCoordinate2D(latitude: flightConnection.coordinates.to.lat,
                                         longitude: flightConnection.coordinates.to.long)
        DispatchQueue.main.async {
            let polyline = MKPolyline(coordinates:[self.fromCoord, self.toCoord], count: 2)
            self.routeToAirport.setRegion(MKCoordinateRegion(self.getRegionRectFor(route: polyline)), animated: true)
            self.routeToAirport.addOverlay(polyline)
        }
    }
    
    func getRegionRectFor(route: MKPolyline) ->  MKMapRect{
        var regionRect = route.boundingMapRect
        
        let wPadding = regionRect.size.width * 0.5
        let hPadding = regionRect.size.height * 0.5
        
        regionRect.size.width += wPadding
        regionRect.size.height += hPadding
        
        regionRect.origin.x -= wPadding / 2
        regionRect.origin.y -= hPadding / 2
        return regionRect
    }
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        
        routeToAirport.showsCompass =  true
        routeToAirport.showsTraffic = true
        routeToAirport.showsBuildings = true
        routeToAirport.showsPointsOfInterest = true
        
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.red
            renderer.lineWidth = 2.5
            return renderer
        }
        return MKOverlayRenderer()
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        return nil
    }
    
}
