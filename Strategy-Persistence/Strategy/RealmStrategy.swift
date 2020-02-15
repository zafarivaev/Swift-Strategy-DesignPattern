//
//  RealmStrategy.swift
//  Strategy-Persistence
//
//  Created by Zafar on 2/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import RealmSwift

class RealmStrategy: PersistenceStrategy {
    
    var title: String = "RealmStrategy"
    
    func addItem(title: String) -> Item? {
        
        let realm = try! Realm()
        let realmItem = RealmItem(title: title, id: UUID().uuidString)
        do {
            try realm.write {
                realm.add(realmItem)
            }
            
            return Item(title: realmItem.title,
                        id: realmItem.id)
        } catch {
            print(error)
            return nil
        }
    }
    
    func getItems() -> [Item] {
        
        let realm = try! Realm()
        let realmItems = realm.objects(RealmItem.self)
        
        let items: [Item] = realmItems.compactMap { Item(title: $0.title, id: $0.id)
        }
        
        return items
    }
    
    func editItem(id: String, newTitle: String, success: @escaping () -> ()) {
        
        let realm = try! Realm()
        let realmItem = realm.objects(RealmItem.self)
            .filter { $0.id == id }
            .first
        
        do {
            if realmItem != nil {
                try realm.write {
                    realmItem!.title = newTitle
                    success()
                }
            }
        } catch {
            print(error)
        }
        
    }
    
    func deleteItem(id: String, success: @escaping () -> ()) {
        
        let realm = try! Realm()
        let itemToDelete = realm.objects(RealmItem.self)
            .filter { $0.id == id }
            .first
        
        do {
            if let object = itemToDelete {
                try realm.write {
                    realm.delete(object)
                    success()
                }
            }
        } catch {
            print(error)
        }
        
    }
}
