//
//  FavListViewController.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 24/09/2021.
//

import UIKit
import CoreData

class FavListViewController: UIViewController, UITableViewDelegate, UISearchBarDelegate, UITableViewDataSource {
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var favs: [Museo] = []
    var asyncFetchRequest: NSAsynchronousFetchRequest<Museo>!
    
    @IBOutlet weak var favTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        favTableView.delegate = self
        favTableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        let managedContext = MuseumsModel.shared.managedContext
        let favFetchRequest = NSFetchRequest<Museo>(entityName: "Museo")
        
        asyncFetchRequest = NSAsynchronousFetchRequest(fetchRequest: favFetchRequest) {
          [unowned self] (result: NSAsynchronousFetchResult!) -> Void in
            self.favs = result.finalResult!
            favTableView.reloadData()
        }
        do {
            try managedContext?.execute(asyncFetchRequest)
        } catch let error as NSError {
          print("Could not fetch \(error), \(error.userInfo)")
        }
        
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return favs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let favoriteCell = tableView.dequeueReusableCell(withIdentifier: "FavouriteCell") as! FavTableViewCell

        let favMuseum = favs[indexPath.row]
        favoriteCell.titleLabel.text = favMuseum.nombreEntidad
        favoriteCell.locationLabel.text = favMuseum.localidad
        
        switch favMuseum.directorio {
            case "Centros de interpretación":
                favoriteCell.backgroundColor = UIColor(red: 130/255, green: 224/255, blue: 170/255, alpha: 0.45)
            case "Colecciones visitables":
                favoriteCell.backgroundColor = UIColor(red: 174/255, green: 214/255, blue: 241/255, alpha: 0.45)
            case "Museos":
                favoriteCell.backgroundColor = UIColor(red: 187/255, green: 143/255, blue: 206/255, alpha: 0.45)
        default:
            favoriteCell.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        }

        return favoriteCell
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "Borrar"
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    {
        guard editingStyle == .delete else {
            return
        }
        let managedContext = MuseumsModel.shared.managedContext
        let favMuseum = favs[indexPath.row]
        managedContext?.delete(favMuseum)
        favs.remove(at: indexPath.row)
        
        do {
            try managedContext?.save()
        
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        tableView.reloadData()
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
            case "detailFavSegue":
                if let indexPath = favTableView.indexPathForSelectedRow {
                    let detailVC = segue.destination as! DetailViewController
                    detailVC.museo = setDataFromDB(museo: favs[indexPath.row])
                }
            
            default:
                print("Unknown segue id: \(segue.identifier!)")
        }
    }
    
    func setDataFromDB(museo: Museo) -> Record {
        let record: Record = Record(museo: museo)
        return record
    }

}
