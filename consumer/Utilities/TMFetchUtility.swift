//
//  TMFetchUtility.swift
//  consumer
//
//  Created by Vladislav Zagorodnyuk on 3/16/16.
//  Copyright © 2016 Human Ventures Co. All rights reserved.
//

import CoreData

extension NSFetchedResultsController {
    
    func getSectionsCount()-> Int {
        
        guard let _sectionsCount = self.sections?.count else {
            
            return 0
        }
        
        return _sectionsCount
    }
    
    func getRowCount(forSection section: Int)-> Int {
        
        guard let sectionObject = self.sections?[section] else {
            
            return 0
        }
        
        return sectionObject.numberOfObjects
    }
    
    func getObject(forIndexPath indexPath: IndexPath)-> Any? {
        
        guard let fetchedObject = self.sections?[indexPath.section].objects?[indexPath.row] else {
            
            return nil
        }
        
        return fetchedObject
    }
    
}
