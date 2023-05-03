//
//  AddPassView.swift
//  pass-wallet-prototype
//
//  Created by HoSeon Chu on 2023/04/27.
//

import Foundation
import PassKit
import SwiftUI
import UIKit

struct AddPassView: UIViewControllerRepresentable {
    typealias UIViewControllerType = PKAddPassesViewController
    
    @Environment(\.presentationMode) var presentationMode
    
    @Binding var pass: PKPass?
    
    func makeUIViewController(context: Context) -> PKAddPassesViewController {
        let passVC = PKAddPassesViewController(pass: self.pass!)
        return passVC!
    }
    
    func updateUIViewController(_ uiViewController: PKAddPassesViewController, context: Context) {
        //
    }
    
    
    
    
}
