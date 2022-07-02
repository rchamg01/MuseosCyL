//
//  MuseumsList.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 20/07/2021.
//

import Foundation

// MARK: - MuseumsList
struct MuseumsList: Decodable {
    var nhits: Int
    var parameters: Parameters
    var records: [Record]
}

// MARK: - Parameters
struct Parameters: Decodable {
    var rows, start: Int
}

// MARK: - Record
struct Record: Decodable {
    var recordid: String
    var fields: Fields
    
    init(museo: Museo) {
        self.recordid = ""
        self.fields = Fields(museo: museo)
    }
    
}

// MARK: - Fields
struct Fields: Decodable {
    var serviciosDisponibles: String?
    var nombreentidad: String
    var horarioDeApertura: String?
    var posicion: [Double]?
    var informacionAdicional: String
    var requisitosEspecificosParaElAcceso: String?
    var directorioSuperior: DirectorioSuperior
    var localidad: String
    var enlaceAlContenido: String
    var distance: Double = 0
    
    enum CodingKeys: String, CodingKey {
        case serviciosDisponibles = "servicios_disponibles"
        case nombreentidad
        case horarioDeApertura = "horario_de_apertura"
        case posicion
        case informacionAdicional = "informacion_adicional"
        case requisitosEspecificosParaElAcceso = "requisitos_especificos_para_el_acceso"
        case directorioSuperior = "directorio_superior"
        case localidad
        case enlaceAlContenido = "enlace_al_contenido"
    }
    
    init(museo: Museo) {
        self.serviciosDisponibles = museo.servicios
        self.nombreentidad = museo.nombreEntidad ?? ""
        self.horarioDeApertura = museo.horario
        self.posicion = [museo.posicionLat, museo.posicionLon]
        self.informacionAdicional = museo.informacion ?? ""
        self.requisitosEspecificosParaElAcceso = museo.requisitos
        self.directorioSuperior = DirectorioSuperior(rawValue: museo.directorio ?? "desconocido")!
        self.localidad = museo.localidad ?? ""
        self.enlaceAlContenido = museo.enlace ?? ""
    }
    
}

enum DirectorioSuperior: String, Decodable {
    case centrosDeInterpretación = "Centros de interpretación"
    case coleccionesVisitables = "Colecciones visitables"
    case museos = "Museos"
}
