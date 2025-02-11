//
//  DataController.swift
//  Reciplease
//
//  Created by Bilal Dallali on 11/02/2025.
//

import Foundation
import CoreData

class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "Reciplease")
    
    init () {
        container.loadPersistentStores { description, error in
            if let error = error {
                print("Unresolved error \(error.localizedDescription)")
            }
        }
    }
}
