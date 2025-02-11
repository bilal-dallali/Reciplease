//
//  RecipleaseApp.swift
//  Reciplease
//
//  Created by Bilal Dallali on 26/09/2024.
//

import SwiftUI
import Alamofire

@main
struct RecipleaseApp: App {
    
    //let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            RecipeTabView()
                //.environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}

