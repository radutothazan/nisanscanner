//
//  File.swift
//  NisanScanner
//
//  Created by Radu Tothazan on 02/12/2016.
//  Copyright © 2016 Radu Tothazan. All rights reserved.
//

import Foundation
import ObjectMapper

class Produs : Mappable{
    var codBare : String!
    var nume : String!
    var pretVanzare : String!
    var pretAchizitie : String!
    var stoc : String!
    var tva : String!
    
    init(){
    }
    
    required init?(map: Map) {
    }
    
    func mapping(map: Map){
        codBare       <- map["CODBARE"]
        nume          <- map["MATERIALE"]
        pretVanzare   <- map["PRETUNITAR"]
        pretAchizitie <- map["pretFrun"]
        stoc          <- map["STOCFINAL"]
        tva           <- map["TVA"]
    }

}
