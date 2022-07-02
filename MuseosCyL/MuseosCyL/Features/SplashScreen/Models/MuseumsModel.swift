//
//  MuseumsModel.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 21/07/2021.
//

import Foundation
import Alamofire
import CoreData
import UIKit

class MuseumsModel {

    var session = Session.default
    static let shared = MuseumsModel()
    var coreDataStack = CoreDataStack()
    var managedContext: NSManagedObjectContext! {
        get {
            return coreDataStack.context
        }
    }
    
    var museos = [Record]()
    func requestData(onSuccess success: @escaping ([Record]) -> Void,
                     onFail fail: @escaping () -> Void) {
        let url = "https://analisis.datosabiertos.jcyl.es/api/records/1.0/search/?dataset=museos&rows=20&start=\(museos.count)"
        
        session.request(url, method: .get).validate().responseDecodable(of: MuseumsList.self) { (response) in
            guard let raw = response.value else {
                fail()
                return
            }
            if raw.records.isEmpty {
                success(self.museos)
            } else {
                self.museos.append(contentsOf: raw.records)
                self.requestData { museos in
                    success(museos)
                } onFail: {
                    fail()
                }
            }
        }
    }

    func getMuseos() -> [Record] {
      return museos
    }
    
    func save(museo: Record, vc: UIViewController) {
        let entityMuseo = NSEntityDescription.entity(forEntityName: "Museo", in:managedContext)!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Museo")
        let predicate = NSPredicate(format: "nombreEntidad == %@", museo.fields.nombreentidad )
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        
        do {
            let count = try managedContext.count(for: fetchRequest)
            if count == 0 {
                let museum = Museo(entity: entityMuseo, insertInto: managedContext)
                museum.nombreEntidad = museo.fields.nombreentidad
                museum.directorio = museo.fields.directorioSuperior.rawValue
                museum.horario = museo.fields.horarioDeApertura
                museum.informacion = museo.fields.informacionAdicional
                museum.localidad = museo.fields.localidad
                museum.posicionLat = (museo.fields.posicion?.first!)!
                museum.posicionLon = (museo.fields.posicion?.last!)!
                museum.requisitos = museo.fields.requisitosEspecificosParaElAcceso
                museum.servicios = museo.fields.serviciosDisponibles
                museum.enlace = museo.fields.enlaceAlContenido
                coreDataStack.saveContext()
                showAlert(vc: vc, title: "Museo añadido", message: "El museo se ha guardado en la lista de favoritos")
                                    
            } else {
                showAlert(vc: vc, title: "Museo ya añadido", message: "Este museo ya está guardado en la lista de favoritos")
            }
            
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
        
    }
    
    func showAlert(vc: UIViewController ,title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        vc.present(alert, animated: true, completion: nil)
    }
    
}
