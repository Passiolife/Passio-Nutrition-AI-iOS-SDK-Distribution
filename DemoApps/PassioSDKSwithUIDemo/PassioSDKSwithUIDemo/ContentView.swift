//
//  ContentView.swift
//  PassioSDKSwithUIDemo
//
//  Created by Zvika on 4/6/23.
//  Copyright © 2023 Passiolife Inc. All rights reserved.

import SwiftUI
import PassioNutritionAISDK

struct ContentView: View {
    
    @State var foodBinder: FoodRecognitionBinder?
    @State var messageBinder: String?
    @State var sdkConfigured = false
    
    let passioSDK = PassioNutritionAI.shared
    
    var passioID: PassioID? {
        foodBinder?.candidates?.detectedCandidates.first?.passioID
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            PassioRepresentable(foodBinder: $foodBinder,
                                messagesBinder: $messageBinder,
                                sdkConfigured: $sdkConfigured)
            ZStack(alignment: .leading) {
                Text(getNameOfFood)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .foregroundColor(.black)
                    .padding()
                    .background(.gray.opacity(0.5))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.black, lineWidth: 1)
                    )
                if let image = foundImage {
                    image
                        .resizable()
                        .frame(width: 46, height: 46)
                        .cornerRadius(46)
                        .overlay(
                            RoundedRectangle(cornerRadius: 46)
                                .stroke(.black, lineWidth: 1)
                        )
                }
                if passioID == nil {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(2)
                        .padding()
                }
            }.padding()
        }
    }
    
    var foundImage: Image? {
        guard let passioID = passioID else {
            return nil
        }
        let (image, _) = passioSDK.lookupIconFor(passioID: passioID)
        return Image(uiImage: image)
    }
    
    var getNameOfFood: String {
        
        if let message = messageBinder {
            return message
        } else if let passioID = passioID {
            let name = passioSDK.lookupNameFor(passioID: passioID) ?? "No Name"
            return "\(name.capitalized)"
        } else if sdkConfigured {
            return "Keep scanning for food"
        } else {
            return "SDK is being configured"
        }
    }
}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView()
    }
    
}
