//
//  TMCoreDataManager.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 1/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit
import CoreStore
import PromiseKit

class TMCoreDataManager {
    
    // Default token Stack
    static let defaultStack: DataStack = {
        
        let bundleID = Bundle.main.bundleIdentifier!

        let dataStack = DataStack(modelName: "TMModel")
        try! dataStack.addStorageAndWait(
            SQLiteStore(
                fileName: "Test.sqlite",
                localStorageOptions: .recreateStoreOnModelMismatch
        ))
        
        return dataStack
    }()
    
    class func clearDB() {
        
        let entityTypes = self.defaultStack.entityTypesByName.values
        self.defaultStack.beginSynchronous { transaction -> Void in
        
            entityTypes
                .filter { $0 != TMRequestAttribute.self && $0 != TMProduct.self }
                .forEach { transaction.deleteAll(From($0)) }
        
            _ = transaction.commitAndWait()
        }
    }
    
    // MARK: - Promises
    // MARK: - Insertion promises
    class func insertSync<T>(_ into: Into<T>, source: T.ImportSource)-> Promise<T?> where T: NSManagedObject, T: ImportableUniqueObject {
    
        return Promise { fulfill, reject in
         
            self.defaultStack.beginSynchronous { transaction in
                
                do {
                    
                    let importResult = try transaction.importUniqueObject(into, source: source)
                    let _ = transaction.commit()
                    
                    fulfill(importResult)
                }
                catch let error {
                    
                    reject(error)
                }
            }
        }
    }
    
    class func insertSync<T, S: Sequence>(_ into: Into<T>, source: S)-> Promise<[T]> where T: NSManagedObject, T: ImportableUniqueObject, S.Iterator.Element == T.ImportSource {
        
        return Promise { fulfill, reject in
            
            self.defaultStack.beginSynchronous { transaction in
                
                do {
                    
                    let importResult = try transaction.importUniqueObjects(into, sourceArray: source)
                    let _ = transaction.commit()
                    
                    fulfill(importResult)
                }
                catch let error {
                    
                    reject(error)
                }
            }
        }
    }
    
    class func insertASync<T>(_ into: Into<T>, source: T.ImportSource)-> Promise<T?> where T: NSManagedObject, T: ImportableUniqueObject {
        
        return Promise { fulfill, reject in
            
            self.defaultStack.beginAsynchronous { transaction in
                
                do {
                    
                    let importResult = try transaction.importUniqueObject(into, source: source)
                    
                    let _ = transaction.commit { result in
                        switch result {
                        case .success:
                            fulfill(importResult)
                            
                        case .failure(let error):
                            reject(error)
                        }
                    }
                }
                catch let error {
                    
                    reject(error)
                }
            }
        }
    }
    
    class func insertASync<T, S: Sequence>(_ into: Into<T>, source: S)-> Promise<[T]> where T: NSManagedObject, T: ImportableUniqueObject, S.Iterator.Element == T.ImportSource {
        
        return Promise { fulfill, reject in
            
            self.defaultStack.beginAsynchronous { transaction in
                
                do {
                
                    let importResult = try transaction.importUniqueObjects(into, sourceArray: source)
                    
                    let _ = transaction.commit { result in
                        switch result {
                        case .success:
                            fulfill(importResult)
                            
                        case .failure(let error):
                            reject(error)
                        }
                    }
                }
                catch let error {
                    
                    reject(error)
                }
            }
        }
    }
    
    // MARK: - Deletion promises
    class func deleteASync<S: Sequence>(_ objects: S)-> Promise<Bool> where S.Iterator.Element: NSManagedObject {
        
        return Promise { fulfill, reject in
         
            self.defaultStack.beginAsynchronous { transaction in
    
                transaction.delete(objects)
                let _ = transaction.commit { result in
                    switch result {
                    case .success:
                        fulfill(true)
                        
                    case .failure(let error):
                        reject(error)
                    }
                }
            }
        }
    }
    
    class func fetchExisting<T: NSManagedObject>(_ object: T?)-> Promise<T?> {
        return Promise { fulfill, reject in
         
            if let object = object {
                fulfill(self.defaultStack.fetchExisting(object))
            }
            
            fulfill(object)
        }
    }
    
    class func fetchExisting<T: NSManagedObject, S: Sequence>(_ objects: S)-> Promise<[T]> where S.Iterator.Element == T {
        return Promise { fulfill, reject in

            fulfill(self.defaultStack.fetchExisting(objects))
        }
    }
    
    class func fetchAsyncExisting<T: NSManagedObject>(_ object: T?)-> Promise<T?> {
        return Promise { fulfill, reject in
            
            if let object = object {
                self.defaultStack.beginAsynchronous { transaction in
                 
                    fulfill(transaction.fetchExisting(object))
                }
            }
            
            fulfill(object)
        }
    }
}
