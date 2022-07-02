//
//  MuseumsList.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 11/10/2021.
//

import Foundation

// MARK: - MonumentsList
struct MonumentsList: Codable {
    var recordid: String
    var fields: MFields

    enum CodingKeys: String, CodingKey {
        case recordid, fields
    }
}

// MARK: - Fields
struct MFields: Codable {
    var poblacionProvincia: PoblacionProvincia
    var identificador: String
    var ptoGeolocalizado: [Double]
    var descripcion: String?
    var periodohistorico: String?
    var poblacionLocalidad: String
    var tipoconstruccion: String?
    var nombre: String
    var tipomonumento: Tipomonumento

    enum CodingKeys: String, CodingKey {
        case poblacionProvincia = "poblacion_provincia"
        case identificador
        case ptoGeolocalizado = "pto_geolocalizado"
        case descripcion
        case periodohistorico
        case poblacionLocalidad = "poblacion_localidad"
        case tipoconstruccion, nombre, tipomonumento
    }
}

enum PoblacionProvincia: String, Codable {
    case burgos = "Burgos"
    case león = "León"
    case palencia = "Palencia"
    case salamanca = "Salamanca"
    case segovia = "Segovia"
    case soria = "Soria"
    case valladolid = "Valladolid"
    case zamora = "Zamora"
    case ávila = "Ávila"
}

enum Tipomonumento: String, Codable {
    case casasConsistoriales = "Casas Consistoriales"
    case casasNobles = "Casas Nobles"
    case castillos = "Castillos"
    case catedrales = "Catedrales"
    case conjuntoEtnológico = "Conjunto Etnológico"
    case cruceros = "Cruceros"
    case esculturas = "Esculturas"
    case fuentes = "Fuentes"
    case hórreos = "Hórreos"
    case iglesiasYErmitas = "Iglesias y Ermitas"
    case jardínHistórico = "Jardín Histórico"
    case molinos = "Molinos"
    case monasterios = "Monasterios"
    case murallasYPuertas = "Murallas y puertas"
    case otrosEdificios = "Otros edificios"
    case palacios = "Palacios"
    case parajePintoresco = "Paraje pintoresco"
    case plazasMayores = "Plazas Mayores"
    case puentes = "Puentes"
    case realesSitios = "Reales Sitios"
    case santuarios = "Santuarios"
    case sinagogas = "Sinagogas"
    case sitioHistórico = "Sitio Histórico"
    case torres = "Torres"
    case yacimientosArqueológicos = "Yacimientos arqueológicos"
}
