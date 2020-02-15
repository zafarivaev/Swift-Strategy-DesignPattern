//
//  RealmItem.swift
//  Strategy-Persistence
//
//  Created by Zafar on 2/15/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import RealmSwift

class RealmItem: Object {
    
    @objc dynamic var title: String = ""
    @objc dynamic var id: String = ""
    
    convenience init(title: String, id: String) {
        self.init()
        self.title = title
        self.id = id
    }
}
