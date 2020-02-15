//
//  PersistenceStrategy.swift
//  Strategy-Persistence
//
//  Created by Zafar on 2/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import Foundation

protocol PersistenceStrategy: class {
    var title: String { get }
    
    func addItem(title: String) -> Item?
    func getItems() -> [Item]
    func editItem(id: String, newTitle: String, success: @escaping () -> ())
    func deleteItem(id: String, success: @escaping () -> ())
}
