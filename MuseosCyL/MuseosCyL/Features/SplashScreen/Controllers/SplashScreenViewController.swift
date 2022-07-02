//
//  SplashScreenViewController.swift
//  MuseosCyL
//
//  Created by Raquel on 21/06/2021.
//

import UIKit
import Foundation

import CoreLocation

class SplashScreenViewController: UIViewController, CLLocationManagerDelegate {

    let museumsModel = MuseumsModel.shared
    let monumentsModel = MonumentsModel.shared
    var museos = [Record]()
    var monumentos = [MonumentsList]()
    var locationManager: CLLocationManager!
    var coordinate: CLLocation?
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    //ayuda: https://stackoverflow.com/questions/25296691/get-users-current-location-coordinates
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        if status != .authorizedAlways && status != .authorizedWhenInUse && status != .notDetermined{
            self.coordinate = CLLocation(latitude: 0, longitude: 0)
        
            museumsModel.requestData(
                onSuccess: { (museos) in
                    self.museos = museos
                    self.performSegue(withIdentifier: "LoadData", sender: self)
            }, onFail: {
                self.lanzarError()
            })
            
        }else if status == .notDetermined {
                return
            
        } else {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
            
            self.coordinate = CLLocation(latitude: (manager.location?.coordinate.latitude)!, longitude: (manager.location?.coordinate.longitude)!)
            museumsModel.requestData(
                onSuccess: { (museos) in
                    self.museos = museos
                    self.performSegue(withIdentifier: "LoadData", sender: self)
            }, onFail: {
                self.lanzarError()
            })
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        museumsModel.showAlert(vc: self, title: "Error al obtener tu ubicación", message: "Ha habido un error a la hora de detectar tu ubicación. Reinicia la app y prueba de nuevo")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getMonuments()
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    func lanzarError() {
            
        let alert = UIAlertController(title: "Error de búsqueda",
            message: "No ha sido posible cargar la lista de museos. Prueba de nuevo.",
            preferredStyle: .alert)
        
        let acceptAction = UIAlertAction(title: "De acuerdo",
            style: .default,
            handler: { (action:UIAlertAction) -> Void in
        })
            
        alert.addAction(acceptAction)
        present(alert, animated: true, completion: nil)
        
    }
    
    func getMonuments(){
        monumentsModel.requestData { (monumentos) in
            self.monumentos = monumentos
        } onFail: {
            self.lanzarError()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let listVC = segue.destination as? MuseumListViewController {
            listVC.museos = self.museos
            listVC.coordinate = self.coordinate
            listVC.monumentos = self.monumentos
        }
        
    }

}
