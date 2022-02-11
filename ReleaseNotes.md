# Passio SDK V2.1.1. Beta Release Notes

This is version 2.1.1. which is still in Beta. It is not recommended for use in production. API is subject to change from version to version while we optimize it.

## New features for 2.x
* The ML models are compressed. 
* iPhone with DUAL WIDE Camera (iPhone 11, 12) can perform weight estimation of several foods. iPhone 13 and more foods will be added in upcoming releases.
* Data from Open Food Facts (https://en.openfoodfacts.org) was added to the SDK. Each food that contains data from Open Food Facts will be marked by ```public var isOpenFood: Bool.```

This record contains information from Open Food Facts (https://en.openfoodfacts.org), which is made available here under the Open Database License (https://opendatacommons.org/licenses/odbl/1-0)

##  Passio Nutrition-AI Migration from SDK 1.4.x to 2.x:
* Follow the directions in [Migration from 1.4 to 2.1 ](./Migration1.4to2.1.md). 

## To install SDK 2.x - follow README file

* Download the ```PassioSDKQuickStart.zip``` or the ```PassioSDKFullDemo.zip``` and copy the ```PassioSDKiOS.xcframework``` to your project. Make sure you have followed the directions in the README files.
* The SDK will only run on iOS 13 or newer.. The XCFramework is compiled for min iOS version 12.0.

## OpenFood  license copy
Passio Nutrition-AI SDK added data from Open Food Facts (https://en.openfoodfacts.org/).

<sup>Copyright 2022 Passio Inc</sup>