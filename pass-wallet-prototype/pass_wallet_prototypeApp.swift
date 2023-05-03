//
//  pass_wallet_prototypeApp.swift
//  pass-wallet-prototype
//
//  Created by HoSeon Chu on 2023/03/16.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseStorage


@main
struct pass_wallet_prototypeApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
