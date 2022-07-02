//
//  MuseumListViewController.swift
//  MuseosCyL
//
//  Created by Raquel on 15/06/2021.
//

import UIKit
import CoreLocation

class MuseumListViewController: UIViewController, UISearchResultsUpdating, UISearchBarDelegate {
    let searchController = UISearchController()
    var filteredMuseums = [Record]()
    var sortedMuseos = [Record](){
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
    var museos = [Record]() {
        didSet {
            if tableView != nil {
                tableView?.reloadData()
            }
        }
    }
    var monumentos = [MonumentsList]()

    @IBOutlet weak var tableView: UITableView?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initSearchController()
        isSortingOn = false
        _ = self.tabBarController?.viewControllers
        tableView?.delegate = self
        self.navigationItem.setHidesBackButton(true, animated: true);
        tableView?.rowHeight = 130
        tableView?.estimatedRowHeight = UITableView.automaticDimension
    }
    
    func sortMuseums() -> [Record]{
        var inc: Double = 1000
        for museo in museos {
            if (museo.fields.posicion != nil) {
                let museumLocation = CLLocation(latitude: CLLocationDegrees((museo.fields.posicion?.first)!), longitude: CLLocationDegrees((museo.fields.posicion?.last)!))
                let distanceInMeters = coordinate!.distance(from: museumLocation)
                distances.append(distanceInMeters.twoDecimals())
            } else {
                inc = inc + 1
                distances.append(inc)
            }
        }
        let myDictionary = Dictionary( uniqueKeysWithValues: zip(distances, museos))
        let sortedDict = myDictionary.sorted(by: {
            $0.0<$1.0
        })
        var sortedMuseums = [Record]()
        for (_, value) in sortedDict {
            sortedMuseums.append(value)
        }
        return sortedMuseums
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
        searchController.searchBar.scopeButtonTitles = [DirectorioSuperior.museos.rawValue,
                                                        DirectorioSuperior.coleccionesVisitables.rawValue,
                                                        DirectorioSuperior.centrosDeInterpretación.rawValue]
        navigationItem.rightBarButtonItem?.image = UIImage(systemName: "star")
        navigationItem.rightBarButtonItems?.last?.image = UIImage(systemName: "map")
        navigationItem.leftBarButtonItem?.image = UIImage(systemName: "building.2")
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        if coordinate?.coordinate.latitude != 0 && coordinate?.coordinate.longitude != 0 {
            if buttonCount == 0 || buttonCount.isMultiple(of: 2) {
                if buttonCount == 0 {
                    MuseumsModel.shared.showAlert(vc: self, title: "Tus museos más cercanos",
                                                  message: "Con este filtro podrás ordenar los museos según tu ubicación.")
                }
                sortedMuseos = sortMuseums()
                isSortingOn = true
            } else {
                sortedMuseos = museos
                isSortingOn = false
            }
            buttonCount += 1
        } else {
            MuseumsModel.shared.showAlert(vc: self, title: "Necesitamos permisos de ubicación",
                                          message: "Si no aceptas el permiso de ubicación no podemos mostrarte tus museos más cercanos.")
            sortedMuseos = museos
            isSortingOn = false
            buttonCount = 1
        }
    }
    
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        let category = searchBar.scopeButtonTitles![selectedScope]
        filterForSearchText(searchText: searchBar.text!, category: category)
    }


    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        let searchText = searchBar.text!
        let category = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
        filterForSearchText(searchText: searchText, category: category)
    }
    
    //Source:  https://www.raywenderlich.com/4363809-uisearchcontroller-tutorial-getting-started
    func filterForSearchText(searchText: String, category: String) {
        
        filteredMuseums = museos.filter{ museo in
            let doesCategoryMatch = museo.fields.directorioSuperior.rawValue == category
            let searchTextMatch = museo.fields.nombreentidad.contains(insensitive: searchText) ||
                museo.fields.localidad.contains(insensitive: searchText)
            
            if isSearchBarEmpty {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && searchTextMatch
            }
        }
        
        tableView?.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "detailSegue":
                if(searchController.isActive) {
                    if let indexPath = tableView?.indexPathForSelectedRow {
                        let detailVC = segue.destination as! DetailViewController
                        detailVC.museo = filteredMuseums[indexPath.row]
                        detailVC.monumentos = monumentos
                        detailVC.coordinate = coordinate
                        detailVC.museos = museos
                    }
                } else {
                    if isSortingOn {
                        if let indexPath = tableView?.indexPathForSelectedRow {
                            let detailVC = segue.destination as! DetailViewController
                            detailVC.museo = sortedMuseos[indexPath.row]
                            detailVC.monumentos = monumentos
                            detailVC.coordinate = coordinate
                            detailVC.museos = museos
                        }
                    } else {
                        if let indexPath = tableView?.indexPathForSelectedRow {
                            let detailVC = segue.destination as! DetailViewController
                            detailVC.museo = museos[indexPath.row]
                            detailVC.monumentos = monumentos
                            detailVC.coordinate = coordinate
                            detailVC.museos = museos
                        }
                    }
                }
            case "list2listSegue":
                let detailVC = segue.destination as! MonumentListViewController
                detailVC.coordinate = coordinate
                detailVC.monumentos = monumentos
                detailVC.museos = museos
                
            case "favSegue":
                _ = segue.destination as! FavListViewController
            case "mapSegue":
                let mapVC = segue.destination as! MuseumsMapViewController
                mapVC.museos = museos
                mapVC.coordinate = coordinate
                mapVC.monumentos = monumentos
            
            default:
                    print("Unknown segue id: \(segue.identifier!)")
        }
    }
  
}


extension MuseumListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(searchController.isActive) {
            return filteredMuseums.count
        }
        if isSortingOn {
            return sortedMuseos.count
        }
        
        return self.museos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
         let cell = tableView.dequeueReusableCell(withIdentifier: "celda_museo", for: indexPath) as! CustomCell
            
        cell.cellView?.layer.cornerRadius = 8
        cell.cellView?.layer.masksToBounds = true
        var museo: Record
        
        if(searchController.isActive) {
            searchController.searchBar.showsBookmarkButton = false
            museo = filteredMuseums[indexPath.row]
        } else {
            if isSortingOn {
                searchController.searchBar.showsBookmarkButton = true
                museo = self.sortedMuseos[indexPath.row]
            }else {
                searchController.searchBar.showsBookmarkButton = true
                museo = museos[indexPath.row]
            }
        }
        
        switch museo.fields.directorioSuperior {
            case .centrosDeInterpretación:
                cell.cellView?.backgroundColor = UIColor(red: 130/255, green: 224/255, blue: 170/255, alpha: 0.45)
            case .coleccionesVisitables:
                cell.cellView?.backgroundColor = UIColor(red: 174/255, green: 214/255, blue: 241/255, alpha: 0.45)
            case .museos:
                cell.cellView?.backgroundColor = UIColor(red: 187/255, green: 143/255, blue: 206/255, alpha: 0.45)
        }
        
        cell.name?.text = museo.fields.nombreentidad
        cell.localidad?.text = museo.fields.localidad
        cell.tipo.text = museo.fields.directorioSuperior.rawValue
        return cell
    }
}

extension MuseumListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 130.0
    }
}
