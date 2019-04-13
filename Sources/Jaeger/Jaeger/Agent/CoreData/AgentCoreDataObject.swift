//
//  AgentCoreDataObject.swift
//  Jaeger
//
//  Created by Simon-Pierre Roy on 2/1/19.
//

#if canImport(CoreData)
import CoreData

extension NSManagedObjectModel {

    internal enum Jaeger {

        /** The Core Data model for the Agent written in Code. By  writing the model in code, we lose the ability of performing automatic migration.
         To recover this feature, it would require to implement a fully manual migration.
         More specifically, one would need to keep track of all versions and use a `NSMappingModel`
         for each version that supports migration.
         */
        static let sharedAgentModel: NSManagedObjectModel = {

            let model = NSManagedObjectModel()

            // Core Data Span
            let coreDataSpan = NSEntityDescription()
            coreDataSpan.name = "CoreDataSpan"
            coreDataSpan.managedObjectClassName = "CoreDataSpan" // See the CoreDataSpan.swift file

            // Property 1: Binary Data representing the span
            let jsonSpan = NSAttributeDescription()
            jsonSpan.name = "jsonSpan"
            jsonSpan.attributeType = .binaryDataAttributeType
            jsonSpan.isOptional = false
            jsonSpan.allowsExternalBinaryDataStorage = true

            // Property 2: the span start time, it is useful to order queries
            let startTime = NSAttributeDescription()
            startTime.name = "startTime"
            startTime.attributeType = .dateAttributeType
            jsonSpan.isOptional = false

            coreDataSpan.properties = [jsonSpan, startTime]
            model.entities = [coreDataSpan]

            return model
        }()
    }
}
#endif
