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
    
    @StateObject private var dataController = DataController()
    
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                RecipeTabView()
            }
            .environment(\.managedObjectContext, dataController.container.viewContext)
        }
    }
}

