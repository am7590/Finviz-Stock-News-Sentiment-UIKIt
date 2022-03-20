//
//  SearchResults.swift
//  uikit-dca-calculator
//
//  Created by Alek Michelson on 3/2/22.
//
 
import Foundation
 
struct SearchResults: Decodable {
    
    let items: [SearchResult]
 
    // Map JSON values from API to variables with a different name
    enum CodingKeys: String, CodingKey {
        case items = "bestMatches"
    }
    
}
 
 
struct SearchResult: Decodable {
    let symbol: String
    let name: String
    let type: StringLiteralType
    let currency: String
    
    // Map JSON values from API to variables with a different name
    enum CodingKeys: String, CodingKey {
        case symbol = "1. symbol"
        case name = "2. name"
        case type = "3. type"
        case currency = "8. currency"
    }
    
}
 

