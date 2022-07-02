//
//  MuseumsMapViewController.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 11/10/2021.
//

import UIKit
import MapKit

class MuseumsMapViewController: UIViewController, MKMapViewDelegate{

    var coordinate: CLLocation?
    var museos = [Record]()
    var monumentos = [MonumentsList]()
    var annotationView = MKMarkerAnnotationView()
    
    @IBOutlet weak var museumsMap: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        museumsMap.delegate = self
        self.museumsMap.showsUserLocation = true
        setData()
    }
    
    private func setData() {
        for museo in museos {
            if let posicion = museo.fields.posicion {
                let annotation = MKPointAnnotation()
                annotation.title = museo.fields.nombreentidad
                annotation.subtitle = museo.fields.directorioSuperior.rawValue
                annotation.coordinate = CLLocationCoordinate2D(latitude: posicion.first!, longitude: posicion.last!)
                museumsMap.addAnnotation(annotation)
            }
        }
        for monumento in monumentos {
            let annotation = MKPointAnnotation()
            annotation.title = monumento.fields.nombre
            annotation.subtitle = monumento.fields.tipomonumento.rawValue
            annotation.coordinate = CLLocationCoordinate2D(latitude: monumento.fields.ptoGeolocalizado.first!, longitude: monumento.fields.ptoGeolocalizado.last!)
            museumsMap.addAnnotation(annotation)
        }
        if coordinate?.coordinate.latitude != 0 && coordinate?.coordinate.longitude != 0 {
            let viewRegion = MKCoordinateRegion(center: coordinate!.coordinate, latitudinalMeters: 15000, longitudinalMeters: 15000)
            museumsMap.setRegion(viewRegion, animated: false)
        }else{
            let coordinateC = CLLocationCoordinate2D(latitude: 41.726479, longitude: -4.723742)
            let viewRegion = MKCoordinateRegion(center: coordinateC, latitudinalMeters: 300000, longitudinalMeters: 300000)
            museumsMap.setRegion(viewRegion, animated: false)
        }
    
    }

}
