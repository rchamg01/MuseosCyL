//
//  MonumentListViewController.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 12/10/2021.
//

import UIKit
import CoreLocation

class MonumentListViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {

    let searchController = UISearchController()
    var filteredMonuments = [MonumentsList]()
    var sortedMonuments = [MonumentsList](){
        didSet {
            if tableView != nil {
                tableView?.reloadData()
            }
        }
    }
    var coordinate: CLLocation?
    var isSortingOn: Bool = false
    var buttonCount: Int = 0
    var distances = [Double]()
    var museos = [Record]()
    var monumentos = [MonumentsList]() {
        didSet {
            if tableView != nil {
                tableView?.reloadData()
            }
        }
    }
    
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
        isSortingOn = false
        _ = self.tabBarController?.viewControllers
        tableView?.delegate = self
        tableView?.rowHeight = 130
        tableView?.estimatedRowHeight = UITableView.automaticDimension
    }
    
    func sortMonuments() -> [MonumentsList]{
        var inc: Double = 0
        for monumento in monumentos {
            let monumentLocation = CLLocation(latitude: CLLocationDegrees(monumento.fields.ptoGeolocalizado.first!), longitude: CLLocationDegrees(monumento.fields.ptoGeolocalizado.last!))
            let distanceInMeters = coordinate!.distance(from: monumentLocation)
            inc = inc + 0.0000000001
            distances.append(distanceInMeters + inc)
        }
        
        let myDictionary = Dictionary( uniqueKeysWithValues: zip(distances, monumentos))
        let sortedDict = myDictionary.sorted(by: {
            $0.0<$1.0
        })
        var sortedMonuments = [MonumentsList]()
        for (_, value) in sortedDict {
            sortedMonuments.append(value)
        }
        return sortedMonuments
    }
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    var isFiltering: Bool {
      let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
      return searchController.isActive && (!isSearchBarEmpty || searchBarScopeIsFiltering)
    }
    
    func initSearchController() {
        definesPresentationContext = true
        searchController.loadViewIfNeeded()
        searchController.searchBar.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.returnKeyType = UIReturnKeyType.done
        searchController.searchBar.placeholder = "Busca por nombre, localidad, tipo..."
        searchController.searchBar.setValue("Borrar", forKey: "cancelButtonText")
        searchController.searchBar.showsBookmarkButton = true
        searchController.searchBar.setImage(UIImage(systemName: "text.chevron.right"), for: .bookmark, state: .normal)
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "map")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if coordinate?.coordinate.latitude != 0 && coordinate?.coordinate.longitude != 0 {
            if buttonCount == 0 || buttonCount.isMultiple(of: 2) {
                if buttonCount == 0 {
                    MuseumsModel.shared.showAlert(vc: self, title: "Tus monumentos más cercanos",
                                                  message: "Con este filtro podrás ordenar los monumentos según tu ubicación.")
                }
                sortedMonuments = sortMonuments()
                isSortingOn = true
            } else {
                sortedMonuments = monumentos
                isSortingOn = false
            }
            buttonCount += 1
        } else {
            MuseumsModel.shared.showAlert(vc: self, title: "Necesitamos permisos de ubicación",
                                          message: "Si no aceptas el permiso de ubicación no podemos mostrarte tus monumentos más cercanos.")
            sortedMonuments = monumentos
            isSortingOn = false
            buttonCount = 1
        }
    }

    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text!
        filterForSearchText(searchText: searchText)
    }
    
    //Source:  https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started
    func filterForSearchText(searchText: String) {
        
        filteredMonuments = monumentos.filter{ monumento in
            let searchTextMatch = monumento.fields.nombre.contains(insensitive: searchText) ||
                monumento.fields.poblacionLocalidad.contains(insensitive: searchText) || monumento.fields.tipomonumento.rawValue.contains(insensitive: searchText)
            
            return searchTextMatch
        
        }
        
        tableView?.reloadData()
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "detailMonSegue":
                if(searchController.isActive) {
                    if let indexPath = tableView?.indexPathForSelectedRow {
                        let detailVC = segue.destination as! DetailMonumentViewController
                        detailVC.monumento = filteredMonuments[indexPath.row]
                        detailVC.monumentos = monumentos
                        detailVC.museos = museos
                    }
                } else {
                    if isSortingOn {
                        if let indexPath = tableView?.indexPathForSelectedRow {
                            let detailVC = segue.destination as! DetailMonumentViewController
                            detailVC.monumento = sortedMonuments[indexPath.row]
                            detailVC.monumentos = monumentos
                            detailVC.museos = museos
                        }
                    } else {
                        if let indexPath = tableView?.indexPathForSelectedRow {
                            let detailVC = segue.destination as! DetailMonumentViewController
                            detailVC.monumento = monumentos[indexPath.row]
                            detailVC.monumentos = monumentos
                            detailVC.museos = museos
                        }
                    }
                }
            case "map2Segue":
                let mapVC = segue.destination as! MuseumsMapViewController
                mapVC.museos = museos
                mapVC.coordinate = coordinate
                mapVC.monumentos = monumentos
            
            default:
                    print("Unknown segue id: \(segue.identifier!)")
        }
    }

}

extension MonumentListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchController.isActive) {
            return filteredMonuments.count
        }
        if isSortingOn {
            return sortedMonuments.count
        }
        return self.monumentos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "celda_monumento", for: indexPath) as! MonumentCell
            
        cell.cellView?.layer.cornerRadius = 8
        cell.cellView?.layer.masksToBounds = true
        var monumento: MonumentsList
        
        if(searchController.isActive) {
            searchController.searchBar.showsBookmarkButton = false
            monumento = filteredMonuments[indexPath.row]
        } else {
            if isSortingOn {
                searchController.searchBar.showsBookmarkButton = true
                monumento = self.sortedMonuments[indexPath.row]
            } else {
                searchController.searchBar.showsBookmarkButton = true
                monumento = monumentos[indexPath.row]
            }
        }
        cell.cellView?.backgroundColor = UIColor(red: 167/255, green: 0/255, blue: 16/255, alpha: 1)
        
        cell.nombre?.text = monumento.fields.nombre
        cell.localidad?.text = monumento.fields.poblacionLocalidad + "  (" + monumento.fields.poblacionProvincia.rawValue + ")"
        cell.tipo.text = monumento.fields.tipomonumento.rawValue
        return cell
         
    }
}
 

extension MonumentListViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }

}
