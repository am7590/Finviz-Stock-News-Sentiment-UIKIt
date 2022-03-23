//
//  Stock+CoreDataProperties.swift
//  CoreData-Finviz-Test
//
//  Created by Alek Michelson on 3/23/22.
//
//

import Foundation
import CoreData


extension Stock {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Stock> {
        return NSFetchRequest<Stock>(entityName: "Stock")
    }

    @NSManaged public var name: String?

}

extension Stock : Identifiable {

}
