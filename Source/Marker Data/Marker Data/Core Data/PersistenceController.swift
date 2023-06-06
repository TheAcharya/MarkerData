//
//  PersistenceController.swift
//  Marker Data
//
//  Created by Theo S on 21/05/2023.
//

import Foundation
import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for number in 0..<5 {
            let newItem = Configuration(context: viewContext)
            newItem.name = "Test \(number)"
            newItem.isActiveString = "Inactive"
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "MarkerData")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }

        let description = NSPersistentStoreDescription()
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        container.persistentStoreDescriptions.append(description)
        container.viewContext.mergePolicy = NSMergePolicy.overwrite

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
            
            print("coredata container path = \(storeDescription.url!)")
            
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        insertInitialData(context: container.viewContext)
    }
    
    func insertInitialData(context: NSManagedObjectContext) {
//        let newItem = Configuration(context: context)
//        newItem.name = "Test Initial"
//        newItem.actives = "Inactive"
//        do {
//            try context.save()
//        } catch {
//            print("Error saving = \(error.localizedDescription)")
//
//        }
    }
}
