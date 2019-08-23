//
//  Category.swift
//  Todoey
//
//  Created by Luis Domingues on 20/08/19.
//  Copyright © 2019 Luis Domingues. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    
    @objc dynamic var name : String = ""
    let items = List<Item>() //this pathern comes from Realm and it is like arrays
    //it is the forward relationship
}
