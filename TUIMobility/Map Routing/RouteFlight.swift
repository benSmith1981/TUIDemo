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

class RouteFlight: UIView, CLLocationManagerDelegate {
    
    @IBOutlet weak var flightRoute: MKMapView!
    private var fromCoord = CLLocationCoordinate2D()
    private var toCoord = CLLocationCoordinate2D()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.flightRoute.delegate = self
    }
    
    public func route(flightConnection: Connection) {
        fromCoord = CLLocationCoordinate2D(latitude: flightConnection.coordinates.from.lat,
                                           longitude: flightConnection.coordinates.from.long)
        toCoord = CLLocationCoordinate2D(latitude: flightConnection.coordinates.to.lat,
                                         longitude: flightConnection.coordinates.to.long)
        DispatchQueue.main.async {
            let polyline = MKPolyline(coordinates:[self.fromCoord, self.toCoord], count: 2)
            self.addAnnotations(flightConnection: flightConnection)
            self.flightRoute.setRegion(self.flightRoute.regionThatFits(MKCoordinateRegion(self.getRegionRectFor(route: polyline))),
                                          animated: true)
            self.flightRoute.addOverlay(polyline)
        }
    }
    
    private func addAnnotations(flightConnection: Connection) {
        let fromAnnotation = MKPointAnnotation.init()
        let toAnnotation = MKPointAnnotation.init()
        toAnnotation.title = flightConnection.to
        fromAnnotation.title = flightConnection.from
        fromAnnotation.coordinate = self.fromCoord
        toAnnotation.coordinate = self.toCoord
        self.flightRoute.addAnnotations([fromAnnotation,toAnnotation])
    }
    
    private func getRegionRectFor(route: MKPolyline) ->  MKMapRect{
        var regionRect = route.boundingMapRect
        
        let wPadding = regionRect.size.width * 0.5
        let hPadding = regionRect.size.height * 0.5
        
        regionRect.size.width += wPadding
        regionRect.size.height += hPadding
       
        regionRect.origin.x -= wPadding / 2
        regionRect.origin.y -= hPadding / 2
        return regionRect
    }
    
}
extension RouteFlight: MKMapViewDelegate {
    
    func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
        
        flightRoute.showsCompass =  true
        flightRoute.showsTraffic = true
        flightRoute.showsBuildings = true
        flightRoute.showsPointsOfInterest = true
        
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
