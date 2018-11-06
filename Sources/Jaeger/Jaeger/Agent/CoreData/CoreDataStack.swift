//
//  CoreDataStack.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 11/6/18.
//

import Foundation
import CoreData

/// A wrapper around `NSPersistentContainer` allowing a fail-safe mechanism for the creation and loading of the `NSPersistentStore`.
final class CoreDataStack {
    
    /**
     A list of available `NSPersistentStore` store types.
     
     ````
     case inMemory
     case sql
     ````
     */
    enum StoreType {
        /// The in-memory store type.
        case inMemory
        /// The SQLite database store type.
        case sql
        
        /// The associated string in the CoreData framework.
        fileprivate var rawType: String {
            switch self {
            case .inMemory: return NSInMemoryStoreType
            case .sql: return NSSQLiteStoreType
            }
        }
    }
    
    /**
     Creates a new `CoreDataStack` for a specified model.
     
     - Parameter modelName: The name of the CoreDta model.
     - Parameter folderURL: The folder at which the CoreData files should be created or loaded.
     
     - Warning:
     The folder has to exist in order to load or create the persistent store. Falling to provide an existing folder might result in a runtime crash.
     */
    init(modelName: String,
         folderURL: URL = NSPersistentContainer.defaultDirectoryURL(),
         model: NSManagedObjectModel,
         type: StoreType) {
        
        self.modelName = modelName
        self.folderURL = folderURL
        self.model = model
        self.storeType = type
    }
    
    /// The name of the CoreDta model.
    private let modelName: String
    /// The folder at which the CoreData files should be created or loaded.
    private let folderURL: URL
    /// The model used for the CoreData stack.
    private let model: NSManagedObjectModel
    /// The current `NSPersistentStore` store type.
    let storeType: StoreType
    /// A shared background context created from [newBackgroundContext()](https://developer.apple.com/documentation/coredata/nspersistentcontainer/1640581-newbackgroundcontext).
    private(set) lazy var defaultBackgroundContext: NSManagedObjectContext = {
        return storeContainer.newBackgroundContext()
    }()
    
    /// The underlying `NSPersistentContainer`. The first access to this variable will trigger the loading of the persistent store synchronously.
    private(set) lazy var storeContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
        let description: NSPersistentStoreDescription
        
        switch storeType {
        case .sql:
            let url = folderURL.appendingPathComponent(container.name).appendingPathExtension("sqlite")
            description = NSPersistentStoreDescription(url: url)
        case .inMemory:
            description = NSPersistentStoreDescription()
        }
        
        description.type = storeType.rawType
        container.persistentStoreDescriptions = [description]
        
        container.loadPersistentStores { [weak self] (_, error) in
            guard let error = error  else { return }
            guard let strongSelf = self else { return }
            
            strongSelf.deleteCoreDataFiles(at: container) // will only work for StoreType.sql
            container.loadPersistentStores { (_, error) in
                guard error == nil else {
                    fatalError("Unable to load CoreData stack for Jaeger-swift: \(String(describing: error))")
                }
            }
        }
        
        return container
    }()
    
    /**
     Delete all files on disk used for the `NSPersistentStore` when the `storeType` is `StoreType.sql`.
     
     - Parameter container: A CoreData stack.
     */
    private func deleteCoreDataFiles(at container: NSPersistentContainer) {
        
        guard var sqlUrl = container.persistentStoreDescriptions.first?.url else { return }
        sqlUrl.deletePathExtension()
        
        let coreDataFileUrls: [URL] = ["sqlite", "sqlite-shm", "sqlite-wal"].map {
            return sqlUrl.appendingPathExtension($0)
        }
        
        try? coreDataFileUrls.forEach {
            guard FileManager.default.fileExists(atPath: $0.relativePath) else { return }
            try FileManager.default.removeItem(at: $0)
        }
    }
}
