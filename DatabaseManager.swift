//
//  DatabaseManager.swift
//  Lab_1
//
//  Created by Денис Андриевский on 14.02.2021.
//

import UIKit
import CoreData

protocol DatabaseManager {
    func get<T: NSFetchRequestResult>() throws -> [T]
    func create<T: NSManagedObject>(_ type: T.Type, assign: (T) -> Void) throws
    func clear<T: NSManagedObject>(_ type: T.Type) throws
}

final class DatabaseManagerImpl {
    
    enum DatabaseError: Error {
        case viewContextNotFound
        case objectNotFound
        case entityNotFound
    }
    
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate
    private let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext
    
}

extension DatabaseManagerImpl: DatabaseManager {
    
    func get<T: NSFetchRequestResult>() throws -> [T] {
        guard let viewContext = viewContext else { throw DatabaseError.viewContextNotFound }
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        guard let result = try? viewContext.fetch(request) else { throw DatabaseError.objectNotFound }
        return result
    }
    
    func create<T: NSManagedObject>(_ type: T.Type, assign: (T) -> Void) throws {
        guard let viewContext = viewContext else { throw DatabaseError.viewContextNotFound }
        guard let entity = NSEntityDescription.entity(forEntityName: String(describing: T.self), in: viewContext),
              let object = NSManagedObject(entity: entity, insertInto: viewContext) as? T
        else { throw DatabaseError.entityNotFound }
        assign(object)
        try viewContext.save()
    }
    
    func clear<T: NSManagedObject>(_ type: T.Type) throws {
        guard let viewContext = viewContext,
              let objects = try? get() as [T]
              else { throw DatabaseError.viewContextNotFound }
        for object in objects {
            viewContext.delete(object)
        }
        try viewContext.save()
    }
}
