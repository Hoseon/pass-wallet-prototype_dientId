//
//  ContentView.swift
//  pass-wallet-prototype
//
//  Created by HoSeon Chu on 2023/03/16.
//

import SwiftUI
import Foundation
import PassKit
import Firebase
import FirebaseStorage

struct ContentView: View {
    
    
    @State private var qrText = "https://www.idone.io/ko"
    @State private var thumbnailImageLink = "https://"
    
    @State private var content1 = ""
    @State private var content2 = ""
    
    @State private var primaryLabel = ""
    @State private var primaryValue = ""
    
    @State private var secondaryLabel1 = "출입구역"
    @State private var secondaryValue1 = "정문, 서버실"
    
    @State private var secondaryLabel2 = "발급일"
    @State private var secondaryValue2 = "2023-04-26"
    
    @State private var auxiliaryLabel1 = "직책"
    @State private var auxiliaryValue1 = "사원"
    
    @State private var auxiliaryLabel2 = "만료일"
    @State private var auxiliaryValue2 = "폐기시"
    
    @State private var backgroundColor = Color.white
    @State private var textColor = Color.black
    
    @State private var isLoading = false
    
    @State private var newPass: PKPass?
    
    @State private var passSheetVisible = false
    
    @State private var username: String = ""
    
    let storageRef = Storage.storage().reference()
    
    let uuid = UIDevice.current.identifierForVendor?.uuidString
    
    func getColorHex(color: Color) -> String {
        let colorRGB = color.cgColor?.components!
        var colorHex = Color(red: Double(colorRGB![0]), green: Double(colorRGB![1]), blue: Double(colorRGB![2]), opacity: Double(colorRGB![3])).description
        colorHex = colorHex.replacingOccurrences(of: "#", with: "")
        if (colorHex == "black") {
            return "000000"
        } else if (colorHex == "white") {
            return "FFFFFF"
        } else {
            colorHex = colorHex.dropLast(2).description
            return colorHex
        }
    }
    
    func generatePass(completion: @escaping((Bool) -> () )) {
        let params: [String:Any] = [
            "qrText": self.uuid ?? "Unknown",
            "thumbnail": self.thumbnailImageLink,
            "primary": [
                "value": self.primaryValue,
                "label": self.primaryLabel
            ],
            "secondary": [
                [
                    "value": self.secondaryValue1,
                    "label": self.secondaryLabel1
                ],
                [
                    "value": self.secondaryValue2,
                    "label": self.secondaryLabel2
                ]
            ],
            "auxiliary" : [
                [
                    "value": self.auxiliaryValue1,
                    "label": self.auxiliaryLabel1
                    
                ],
                [
                    "value": self.auxiliaryValue2,
                    "label": self.auxiliaryLabel2
                ]
            ],
            "backgroundColor": self.getColorHex(color: self.backgroundColor),
            "textColor": self.getColorHex(color: self.textColor)
            
        ]
        
        
        
        //
        var request = URLRequest(url: URL(string: "https://devguest.metadna.kr/pkpasses")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            do {
                let json = try JSONSerialization.jsonObject(with: data!) as! [String:Any]
                completion(json["result"]! as! String == "SUCCESS" ? true : false)
            } catch {
                print("error")
                completion(false)
            }
        }
        
        task.resume()
    }
    
    func downloadPass(completion: @escaping((Bool) -> () )) {
        self.storageRef.child("pass/\(self.uuid!).pkpass").getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                print("Error Download File: " + error.localizedDescription)
            }
            else {
                do {
                    let canAddPassResult = PKAddPassesViewController.canAddPasses()
                    if(canAddPassResult) {
                        print("Can add passes, Proceed with create pass.")
                        self.newPass = try PKPass.init(data: data!)
                        completion(true)
                    }
                    else {
                        print("Can NOT add pass. Abort!")
                        completion(false)
                    }
                } catch {
                    print("Something is wrong.")
                    completion(false)
                }
            }
        }
    }
    

    var body: some View {
        
        NavigationView {
            Form {
                Section(header: Text("출입정보")) {
                    TextField("사번", text: $qrText)
                    TextField("썸네일", text: $thumbnailImageLink)
                }
                
                Section(header: Text("기본 필드".uppercased())) {
                    TextField("회사명", text: $primaryLabel)
                    TextField("이름", text: $primaryValue)
                }
                
                Section(header: Text("출입 정보".uppercased())) {
                    TextField("출입구역", text: $secondaryLabel1)
                    TextField("정문, 서버실", text: $secondaryValue1)
                    TextField("발급일", text: $secondaryLabel2)
                    TextField("2023-04-26", text: $secondaryValue2)
                }
                
                Section(header: Text("보조 필드".uppercased())) {
                    TextField("Label", text: $auxiliaryLabel1)
                    TextField("Value", text: $auxiliaryValue1)
                    TextField("Label", text: $auxiliaryLabel2)
                    TextField("Value", text: $auxiliaryValue2)
                }
                
                Section("발급 색상") {
                    ColorPicker("카드색상", selection: $backgroundColor)
                    ColorPicker("폰트 색상", selection: $textColor)
                }
                
                Section("Add to wallet") {
                    if (!self.isLoading) {
                        AddPassToWalletButton {
                            self.isLoading = true
                            self.generatePass { generatePassResult in
                                if(generatePassResult) {
                                    self.downloadPass { downloadPassResult in
                                        if(downloadPassResult) {
                                            self.passSheetVisible = true
                                            self.isLoading = false
                                        } else {
                                            self.isLoading = false
                                            print("failed to download pass")
                                        }
                                    }
                                } else {
                                    self.isLoading = false
                                    print("failed to generate pass")
                                }
                                
                            }
                        }
                    } else {
                        ProgressView()
                    }
                }
                
            }
            .navigationTitle("iD•One Pass")
            .sheet(isPresented: $passSheetVisible) {
                AddPassView(pass: self.$newPass)
            }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
