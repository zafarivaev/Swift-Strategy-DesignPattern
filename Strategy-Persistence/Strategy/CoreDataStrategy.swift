//
//  CoreDataStrategy.swift
//  Strategy-Persistence
//
//  Created by Zafar on 2/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit
import CoreData

class CoreDataStrategy: PersistenceStrategy {
    var title: String = "Core Data Strategy"
    
    func addItem(title: String) -> Item? {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return nil
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let itemEntity = NSEntityDescription.insertNewObject(forEntityName: "CoreDataItem", into: managedContext) as! CoreDataItem
        itemEntity.title = title
        itemEntity.id = UUID().uuidString
        
        do {
            try managedContext.save()
        } catch {
            print(error)
            return nil
        }
        
        return Item(title: itemEntity.title!,
                    id: itemEntity.id!)
    }
    
    func getItems() -> [Item] {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return []
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataItem")
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            if let coreDataItems = result as? [CoreDataItem] {
                let items = coreDataItems
                    .map { Item(
                        title: $0.title!,
                        id: $0.id!)
                    }
                return items
            } else {
                return []
            }
        } catch {
            print("Couldn't get items from Core Data")
            return []
        }
        
    }
    
    func editItem(id: String, newTitle: String, success: @escaping () -> ()) {
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataItem")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            let objectToUpdate = result[0] as! NSManagedObject
            objectToUpdate.setValue(newTitle, forKey: "title")
            
            do {
                try managedContext.save()
                success()
            } catch {
                print(error)
            }
        } catch {
            print(error)
            return
        }
    }
    
    func deleteItem(id: String, success: @escaping () -> ()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CoreDataItem")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        do {
            let result = try managedContext.fetch(fetchRequest)
            
            if let objectToDelete = result.first as? NSManagedObject {
                managedContext.delete(objectToDelete)
                
                do {
                    try managedContext.save()
                    success()
                } catch {
                    print(error)
                }
            }
        } catch {
            print(error)
        }
    }
}

