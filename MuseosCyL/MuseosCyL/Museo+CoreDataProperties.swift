//
//  Museo+CoreDataProperties.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 25/09/2021.
//
//

import Foundation
import CoreData


extension Museo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Museo> {
        return NSFetchRequest<Museo>(entityName: "Museo")
    }

    @NSManaged public var nombreEntidad: String?
    @NSManaged public var directorio: String?
    @NSManaged public var horario: String?
    @NSManaged public var servicios: String?
    @NSManaged public var informacion: String?
    @NSManaged public var requisitos: String?
    @NSManaged public var localidad: String?
    @NSManaged public var enlace: String?
    @NSManaged public var posicionLat: Double
    @NSManaged public var posicionLon: Double

}

extension Museo : Identifiable {

}
