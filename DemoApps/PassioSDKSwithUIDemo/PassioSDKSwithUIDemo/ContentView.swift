//
//  ContentView.swift
//  PassioSDKSwithUIDemo
//
//  Created by Zvika on 4/6/23.
//  Copyright © 2023 Passiolife Inc. All rights reserved.

import SwiftUI
import Combine
import PassioNutritionAISDK

struct ContentView: View {

    @ObservedObject var passioResults: PassioResults

    let passioSDK = PassioNutritionAI.shared

    var body: some View {
        ZStack(alignment: .bottom) {
            PassioRepresentable(passioResults: passioResults)
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
                        .padding(20.0)
                }
            }
            .padding()
        }
        .edgesIgnoringSafeArea(.all)
    }

    var getNameOfFood: String {
        if let message = passioResults.foodRecognitionResults?.downloadingMessage {
            return message
        } else if let passioID = passioID {
            let name = passioSDK.lookupNameFor(passioID: passioID) ?? "No Name"
            return "\(name.capitalized)"
        } else if passioSDK.status.mode == .isReadyForDetection {
            return "Keep scanning for food"
        } else {
            return "SDK is being configured"
        }
    }

    var foundImage: Image? {
        guard let passioID = passioID else {
            return nil
        }
        let (placeHolder, niceImage) = passioSDK.lookupIconsFor(passioID: passioID)
        return Image(uiImage: niceImage ?? placeHolder)
    }

    var passioID: PassioID? {
        passioResults.foodRecognitionResults?.candidates?.detectedCandidates.first?.passioID
    }

}

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView(passioResults: PassioResults())
    }

}
