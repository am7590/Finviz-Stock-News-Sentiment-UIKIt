//
//  Security+CoreDataProperties.swift
//  CoreData-Finviz-Test
//
//  Created by Alek Michelson on 3/23/22.
//
//

import Foundation
import CoreData


extension Security {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Security> {
        return NSFetchRequest<Security>(entityName: "Security")
    }

    @NSManaged public var name: String?

}

extension Security : Identifiable {

}
