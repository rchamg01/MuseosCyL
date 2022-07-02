//
//  DetailMonumentViewController.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 11/10/2021.
//

import UIKit
import MapKit

class DetailMonumentViewController: UIViewController {

    @IBOutlet weak var nombre: UILabel!
    @IBOutlet weak var localidad: UILabel!
    @IBOutlet weak var provincia: UILabel!
    @IBOutlet weak var descripcion: UILabel!
    @IBOutlet weak var periodoHistorico: UILabel!
    @IBOutlet weak var tipoMonumento: UILabel!
    @IBOutlet weak var tipoConstruccion: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableMuseum: UITableView!
    @IBOutlet weak var tableMonuments: UITableView!
    @IBOutlet weak var card: UIView!
    
    var monumentos = [MonumentsList]()
    var closestMon = [MonumentsList]()
    var closestMus = [Record]()
    var museos = [Record]()
    var monumento: MonumentsList!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTables()
        mapView.layer.cornerRadius = 10
        setupNavigationBar()
        setData()
        closestMon = getClosestMonuments()
        closestMus = getClosestMuseums()
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = self.monumento.fields.nombre
        var topItem = navigationController?.navigationBar.topItem?.title
        topItem = title
    }
    
    func setupTables() {
        tableMonuments.delegate = self
        tableMuseum.delegate = self
        tableMonuments.dataSource = self
        tableMuseum.dataSource = self
        tableMonuments.estimatedRowHeight = UITableView.automaticDimension
        tableMuseum.estimatedRowHeight = UITableView.automaticDimension
        tableMonuments.layer.cornerRadius = 15
        tableMuseum.layer.cornerRadius = 15
    }
    
    func getClosestMonuments() -> [MonumentsList] {
        let monumentoLocation = CLLocation(latitude: monumento.fields.ptoGeolocalizado.first!, longitude: monumento.fields.ptoGeolocalizado.last!)
        var closeMonuments = [MonumentsList]()
        for monument in monumentos{
            let monumentLocation = CLLocation(latitude: CLLocationDegrees(monument.fields.ptoGeolocalizado.first!), longitude: CLLocationDegrees((monument.fields.ptoGeolocalizado.last)!))
            let distanceInMeters = monumentoLocation.distance(from: monumentLocation)
            if distanceInMeters < 10000 && distanceInMeters > 3 {
                closeMonuments.append(monument)
            }
        }
        return closeMonuments
    }
    
    func getClosestMuseums() -> [Record] {
        let monumentLocation = CLLocation(latitude: CLLocationDegrees((monumento.fields.ptoGeolocalizado.first)!), longitude: CLLocationDegrees((monumento.fields.ptoGeolocalizado.last)!))
        var closeMuseums = [Record]()
        
        for museo in museos {
            if let posicion = museo.fields.posicion {
                let museoLocation = CLLocation(latitude: CLLocationDegrees((posicion.first)!), longitude: CLLocationDegrees((posicion.last)!))
                let distanceInMeters = museoLocation.distance(from: monumentLocation)
                if distanceInMeters < 10000 && distanceInMeters > 3 {
                    
                    closeMuseums.append(museo)
                }
            }
        }
        return closeMuseums
    }
    
    func setMap() {
        let annotation = MKPointAnnotation()
        annotation.title = self.monumento.fields.nombre
        annotation.subtitle = self.monumento.fields.tipomonumento.rawValue
        annotation.coordinate = CLLocationCoordinate2D(latitude: monumento.fields.ptoGeolocalizado.first!, longitude: monumento.fields.ptoGeolocalizado.last!)
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        mapView.setRegion(region, animated: true)
    }
    
    private func setData() {
        setMap()
        let info = "Sin información disponible."
        self.nombre.text = self.monumento.fields.nombre
        self.localidad.text = self.monumento.fields.poblacionLocalidad
        self.provincia.text = "("+self.monumento.fields.poblacionProvincia.rawValue+")"

        if let descripcion = self.monumento.fields.descripcion {
            self.descripcion.text = descripcion.stripOutHtml()
        } else {
            self.descripcion.text = info
        }
        if let pHistorico = self.monumento.fields.periodohistorico {
            self.periodoHistorico.text = pHistorico
        } else {
            self.periodoHistorico.text = info
        }

        if let tipoConstruccion = self.monumento.fields.tipoconstruccion {
            self.tipoConstruccion.text = tipoConstruccion
        } else {
            self.tipoConstruccion.text = info
        }
        
        self.tipoMonumento.text = self.monumento.fields.tipomonumento.rawValue
        self.card?.layer.cornerRadius = 8
        self.card?.layer.masksToBounds = true
       
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "mon2musSegue":
                if let indexPath = tableMuseum?.indexPathForSelectedRow {
                    let detailVC = segue.destination as! DetailViewController
                    detailVC.museo = closestMus[indexPath.row]
                    detailVC.monumentos = monumentos
                    detailVC.museos = museos
                
                }
            case "d2d2Segue":
                if let indexPath = tableMonuments?.indexPathForSelectedRow {
                    let detailVC = segue.destination as! DetailMonumentViewController
                    detailVC.monumento = closestMon[indexPath.row]
                    detailVC.monumentos = monumentos
                    detailVC.museos = museos
                    self.viewDidLoad()                
                }
                
            default:
                    print("Unknown segue id: \(segue.identifier!)")
        }
    }


}
extension DetailMonumentViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case tableMonuments:
            return self.closestMon.count
        case tableMuseum:
            return self.closestMus.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableView {
        case tableMonuments:
            if closestMon.count == 0 {
                return "No se han encontrado otros puntos de interés cerca"
            }
            return "otros puntos de interés cercanos"
        case tableMuseum:
            if closestMus.count == 0 {
                return "no se han encontrado otros museos cerca"
            }
            return "otros museos de interés cercanos"
        default:
            return ""
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        switch tableView {
        case tableMonuments:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_monumentos", for: indexPath)
            cell.textLabel!.text = closestMon[indexPath.row].fields.nombre + " (" + closestMon[indexPath.row].fields.poblacionLocalidad + ")"
            return cell
        case tableMuseum:
            cell = tableView.dequeueReusableCell(withIdentifier: "cell_museos", for: indexPath)
            cell.textLabel!.text = closestMus[indexPath.row].fields.nombreentidad + " (" + closestMus[indexPath.row].fields.localidad + ")"
            return cell
        default:
            return cell
        }
         
    }
}
 

extension DetailMonumentViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

