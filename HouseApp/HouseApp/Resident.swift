//
//  Resident.swift
//  HouseApp
//
//  Created by reqwwiem on 11.12.2025.
//


struct Resident: Codable {
    let id: String      
    var name: String
    var email: String
    var flat: String
    var phone: String?
    var emergencyContact: String?
    var floor: String?
}
