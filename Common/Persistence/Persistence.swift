//
//  Persistence.swift
//  Dashboard
//
//  Created by Patrick Gatewood on 2/20/19.
//  Copyright © 2019 Patrick Gatewood. All rights reserved.
//

import CoreData
import UIKit

//let appDelegate = UIApplication.shared.delegate as! AppDelegate

protocol Database {
    func getStoredServices() -> [ServiceModel]
    func save(image: UIImage, named fileName: String)
    func renameFile(from oldFileName: String, to newFileName: String)
}

class PersistenceClient {
    static let documentsUrl = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.willowtreeapps.patrick.gatewood.dashboard")!
    
    let fileManager = FileManager.default
    
    static func fetchImage(named: String) -> UIImage? {
        let imageFilePath = documentsUrl.appendingPathComponent("\(named)")
        return UIImage(contentsOfFile: imageFilePath.path)
    }
    
    // MARK: - Core Data stack
    static var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Services")
        let storeUrl = documentsUrl.appendingPathComponent("services.sqlite")
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeUrl)]
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}

extension PersistenceClient: Database {
    func getStoredServices() -> [ServiceModel] {
        let managedContext = PersistenceClient.persistentContainer.viewContext
        let serviceFetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: ServiceModel.entityName)
        
        do {
            let fetchedServices = try managedContext.fetch(serviceFetchRequest) as! [ServiceModel]
            return fetchedServices
        } catch {
            fatalError("Failed to fetch service models: \(error)")
        }
    }
    
    /**
     Saves an image to the shared App Group bundle.
     
     - Parameter image: the image to save
     - Parameter fileName: the name of the file to save the image in. Don't pass the extension.
     */
    func save(image: UIImage, named fileName: String) {
        let imageFilePath = PersistenceClient.documentsUrl.appendingPathComponent("\(fileName)")
        
        do {
            let files = try fileManager.contentsOfDirectory(atPath: PersistenceClient.documentsUrl.path)
            
            if files.contains(imageFilePath.path) {
                try fileManager.removeItem(atPath: imageFilePath.path)
            }
            
            if let imagePngData = image.pngData() {
                try imagePngData.write(to: imageFilePath, options: .atomic)
            }
        } catch {
            print("Failed to save image: \(error)")
        }
    }
    
    func renameFile(from oldFileName: String, to newFileName: String) {
        let oldImageFilePath = PersistenceClient.documentsUrl.appendingPathComponent("\(oldFileName)")
        let newImageFilePath = PersistenceClient.documentsUrl.appendingPathComponent("\(newFileName)")
        
        do {
            try fileManager.moveItem(at: oldImageFilePath, to: newImageFilePath)
        } catch {
            print("Failed to rename image. Saving new instead")
        }
    }
}
