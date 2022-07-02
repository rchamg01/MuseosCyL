//
//  DetailViewController.swift
//  MuseosCyL
//
//  Created by Raquel on 17/06/2021.
//

import UIKit
import MapKit
import CoreData

class DetailViewController: UIViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var monumentos = [MonumentsList]()
    var closestMon = [MonumentsList]()
    var closestMus = [Record]()
    var coordinate: CLLocation?
    var museo: Record!
    var museos = [Record]()
    var favs = [Museo]()
    
    
    @IBOutlet weak var informacion: UILabel?
    @IBOutlet weak var horario: UILabel?
    @IBOutlet weak var location: UILabel?
    @IBOutlet weak var name: UILabel?
    @IBOutlet weak var card: UIView?
    @IBOutlet weak var acceso: UILabel!
    @IBOutlet weak var servicios: UILabel!
    @IBOutlet weak var buttonWeb: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var dView: UIView!
    @IBOutlet weak var tableViewMon: UITableView!
    @IBOutlet weak var tableViewMus: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTables()
        buttonWeb.layer.cornerRadius = 15
        mapView.layer.cornerRadius = 10
        setupNavigationBar()
        setData()
        closestMon = getClosestMonuments()
        closestMus = getClosestMuseums()
    }
    
    @IBAction func btSendWeb(_ sender: Any) {
        UIApplication.shared.open(URL(string: self.museo.fields.enlaceAlContenido)!, options: [:], completionHandler: nil)
    }
    
    func setupTables() {
        tableViewMon.delegate = self
        tableViewMus.delegate = self
        tableViewMon.dataSource = self
        tableViewMus.dataSource = self
        tableViewMon.estimatedRowHeight = UITableView.automaticDimension
        tableViewMus.estimatedRowHeight = UITableView.automaticDimension
        tableViewMon.layer.cornerRadius = 15
        tableViewMus.layer.cornerRadius = 15
    }
    
    func getClosestMonuments() -> [MonumentsList] {
        let museumLocation = CLLocation(latitude: CLLocationDegrees((museo.fields.posicion?.first)!), longitude: CLLocationDegrees((museo.fields.posicion?.last)!))
        var closeMonuments = [MonumentsList]()
        
        for monumento in monumentos{
            if (museo.fields.posicion != nil) {
                let monumentoLocation = CLLocation(latitude: CLLocationDegrees((monumento.fields.ptoGeolocalizado.first)!), longitude: CLLocationDegrees((monumento.fields.ptoGeolocalizado.last)!))
                let distanceInMeters = monumentoLocation.distance(from: museumLocation)
                if distanceInMeters < 10000 && distanceInMeters != 0 {
                    closeMonuments.append(monumento)
                }
            }
        }
        return closeMonuments
    }
        
    func getClosestMuseums() -> [Record] {
        let museumLocation = CLLocation(latitude: CLLocationDegrees((museo.fields.posicion?.first)!), longitude: CLLocationDegrees((museo.fields.posicion?.last)!))
        var closeMuseums = [Record]()
        
        for museo in museos {
            if let posicion = museo.fields.posicion {
                let museoLocation = CLLocation(latitude: CLLocationDegrees((posicion.first)!), longitude: CLLocationDegrees((posicion.last)!))
                let distanceInMeters = museoLocation.distance(from: museumLocation)
                if distanceInMeters < 10000 && distanceInMeters != 0 {
                    closeMuseums.append(museo)
                }
            }
        }
        return closeMuseums
    }
    
    func sortMuseums(distances: [CLLocationDistance], museums: [Record]) -> [Record] {
        
        let myDictionary = Dictionary( uniqueKeysWithValues: zip(distances, museums))
        let sortedDict = myDictionary.sorted(by: {
            $0.0<$1.0
        })
        var sortedMuseums = [Record]()
        for (_, value) in sortedDict {
            sortedMuseums.append(value)
        }
        return sortedMuseums
        
    }
    
    private func setData() {
        if let posicion = self.museo.fields.posicion {
            let annotation = MKPointAnnotation()
            annotation.title = self.museo.fields.nombreentidad
            annotation.subtitle = self.museo.fields.directorioSuperior.rawValue
            annotation.coordinate = CLLocationCoordinate2D(latitude: posicion.first!, longitude: posicion.last!)
            mapView.addAnnotation(annotation)
            let region = MKCoordinateRegion(center: annotation.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
            mapView.setRegion(region, animated: true)
        }
        
        self.name?.text = self.museo.fields.nombreentidad
        self.informacion?.text = self.museo.fields.informacionAdicional.stripOutHtml()
        self.location?.text = self.museo.fields.localidad

        if let horario = self.museo.fields.horarioDeApertura {
            self.horario?.text = horario.stripOutHtml()
        } else {
            self.horario?.text = "Sin información de horario."
        }
        if let acceso = self.museo.fields.requisitosEspecificosParaElAcceso {
            self.acceso.text = acceso.stripOutHtml()
        } else {
            self.acceso.text = "Sin información de acceso."
        }
        
        if let servicios = self.museo.fields.serviciosDisponibles {
            self.servicios.text = servicios.stripOutHtml()
        } else {
            self.servicios.text = "Sin información de los servicios."
        }
       
        switch museo.fields.directorioSuperior {
            case .centrosDeInterpretación:
                self.dView.layer.backgroundColor = CGColor(red: 130/255, green: 224/255, blue: 170/255, alpha: 0.45)
            case .coleccionesVisitables:
                self.dView.layer.backgroundColor = CGColor(red: 174/255, green: 214/255, blue: 241/255, alpha: 0.45)
            case .museos:
                self.dView.layer.backgroundColor = CGColor(red: 187/255, green: 143/255, blue: 206/255, alpha: 0.45)
        }
        
        self.card?.layer.cornerRadius = 8
        self.card?.layer.masksToBounds = true
       
    }
    
    private func setupNavigationBar() {
        self.navigationItem.title = self.museo.fields.nombreentidad
        var topItem = navigationController?.navigationBar.topItem?.title
        topItem = title
    }
    
    @IBAction func favButton(_ sender: Any) {
        MuseumsModel.shared.save(museo: museo, vc: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "monumentSegue":
                if let indexPath = tableViewMon?.indexPathForSelectedRow {
                    let detailVC = segue.destination as! DetailMonumentViewController
                    detailVC.monumentos = monumentos
                    detailVC.monumento = closestMon[indexPath.row]
                    detailVC.museos = museos
                }
                
            case "d2dSegue":
                if let indexPath = tableViewMus?.indexPathForSelectedRow {
                    let detailVC = segue.destination as! DetailViewController
                    detailVC.museo = closestMus[indexPath.row]
                    detailVC.monumentos = monumentos
                    detailVC.coordinate = coordinate
                    detailVC.museos = museos
                    self.viewDidLoad()
                }
                
            default:
                    print("Unknown segue id: \(segue.identifier!)")
        }
    }
    
}

extension DetailViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case tableViewMon:
            return self.closestMon.count
        case tableViewMus:
            return self.closestMus.count
        default:
            return 0
        }
        
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch tableView {
        case tableViewMon:
            if closestMon.count == 0 {
                return "No no se han encontrado otros puntos de interés cerca"
            }
            return "otros puntos de interés cercanos"
        case tableViewMus:
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
        case tableViewMon:
            cell = tableView.dequeueReusableCell(withIdentifier: "celda_mon", for: indexPath)
            cell.textLabel!.text = closestMon[indexPath.row].fields.nombre + " (" + closestMon[indexPath.row].fields.poblacionLocalidad + ")"
            return cell
        case tableViewMus:
            cell = tableView.dequeueReusableCell(withIdentifier: "celda_mus", for: indexPath)
            cell.textLabel!.text = closestMus[indexPath.row].fields.nombreentidad + " (" + closestMus[indexPath.row].fields.localidad + ")"
            return cell
        default:
            return cell
        }
         
    }
}
 

extension DetailViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}

