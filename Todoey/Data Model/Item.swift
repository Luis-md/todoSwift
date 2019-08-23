//
//  Item.swift
//  Todoey
//
//  Created by Luis Domingues on 20/08/19.
//  Copyright © 2019 Luis Domingues. All rights reserved.
//

import Foundation
import RealmSwift

class Item : Object {
    
    @objc dynamic var title : String = ""
    @objc dynamic var done : Bool = false
    @objc dynamic var data: Date?
    
    //making the relationship between the classes
    //it is the reverse relationship
    var parentCategory = LinkingObjects(fromType: Category.self, property: "items")
}
