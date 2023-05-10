//
//  EditProfileViewController.swift
//  PassioPassport
//
//  Created by zvika on 2/28/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif
#if canImport(Firebase)
import Firebase
#endif

class EditProfileViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var buttonDismiss: UIButton!
    @IBOutlet weak var cdcBMI: UILabel!

    let connector = PassioInternalConnector.shared
    let bundlePod = PassioInternalConnector.shared.bundleForModule
    var userProfile: UserProfileModel?
    let bmiText = """
    BMI Categories by the CDC:
    Less than 18.5: Underweight
    Between 18.5 - 24.9: Healthy Weight
    Between 25 – 29.9: Overweight
    Above 30: Obese
    """

    override func viewDidLoad() {
        super.viewDidLoad()
        buttonDismiss.setTitle("", for: .normal)
        connector.fetchUserProfile { (userProfile) in
            self.userProfile = userProfile ?? UserProfileModel()
            self.tableView.reloadData()
        }

        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white],
                                                               for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black],
                                                               for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupTableView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        view.endEditing(true)
        if let userProfile = userProfile {
            connector.updateUserProfile(userProfile: userProfile)
        }
    }

    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        CellsProfile.allCases.forEach {
            let cell = UINib(nibName: $0.rawValue, bundle: bundlePod)
            tableView.register(cell, forCellReuseIdentifier: $0.rawValue)
        }
        tableView.reloadData()
    }

    private enum CellsProfile: String, CaseIterable {
        case ProfileHeaderTableViewCell,
             EditImageTableViewCell,
             EditTextTableViewCell,
             EditMacrosTableViewCell,
             EditPickerTableViewCell,
             EditSwitchTableViewCell,
             LabelTableViewCell
    }

    @IBAction func dimissView(_ sender: UIButton) {
        dismiss(animated: true)
    }

}

extension EditProfileViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = 9
        #if canImport(Firebase)
        numberOfRows = 10
        #endif
        return userProfile == nil ? 0 : numberOfRows
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let userProfile = userProfile else {
            return UITableViewCell()
        }
        switch indexPath.row {
        case 0: // Title
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileHeaderTableViewCell",
                                                           for: indexPath) as?  ProfileHeaderTableViewCell else { return UITableViewCell()
            }
            cell.header.text = "Your profile".localized
            cell.selectionStyle = .none
            return cell
        case 1: // Weight
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextTableViewCell",
                                                           for: indexPath) as? EditTextTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = userProfile.weightTitle
            if let weightDespription = userProfile.weightDespription {
                cell.textValue.text = weightDespription
            } else {
                cell.textValue.text = "Type in".localized
            }
            cell.textValue.tag = indexPath.row
            cell.textValue.delegate = self
            cell.textValue.clearsOnBeginEditing = true
            cell.selectionStyle = .none
            return cell
        case 2: // Height
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPickerTableViewCell",
                                                           for: indexPath) as? EditPickerTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = userProfile.heightTitle
            if let heightDescription = userProfile.heightDescription {
                cell.labelValue.text = heightDescription
            } else {
                cell.labelValue.text = "Select".localized
            }
            cell.selectionStyle = .none
            return cell
        case 3: // Target Calories
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextTableViewCell",
                                                           for: indexPath) as? EditTextTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = "DailyCalories".localized
            cell.textValue.text = String(Int(userProfile.caloriesTarget))
            cell.textValue.tag = indexPath.row
            cell.textValue.delegate = self
            cell.textValue.clearsOnBeginEditing = false
            cell.selectionStyle = .none
            return cell

        case 4: // EditMacrosTableViewCell
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditMacrosTableViewCell", for: indexPath) as? EditMacrosTableViewCell else {
                return UITableViewCell()
            }
            cell.carbsPercent.text = "\(userProfile.carbsPercent)%"
            cell.carbsGrams.text = "(\(userProfile.carbsGrams)g)"
            cell.proteinPercent.text = "\(userProfile.proteinPercent)%"
            cell.proteinGrams.text = "(\(userProfile.proteinGrams)g)"
            cell.fatPercent.text = "\(userProfile.fatPercent)%"
            cell.fatGrams.text = "(\(userProfile.fatGrams)g)"
            cell.selectionStyle = .none
            return cell
        case 5: // gender
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditSwitchTableViewCell",
                                                           for: indexPath) as? EditSwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = "Gender".localized
            cell.segmented.removeAllSegments()
            for (i, key) in GenderSelection.allCases.enumerated() {
                cell.segmented.insertSegment(withTitle: key.rawValue.capitalized.localized,
                                             at: i, animated: false)
            }
            if let _gender = userProfile.gender {
                var selectedSegement: Int = 0
                GenderSelection.allCases.enumerated().forEach {
                    if $0.element == _gender {
                        selectedSegement = $0.offset
                    }
                }
                cell.segmented.selectedSegmentIndex = selectedSegement
            }
            cell.segmented.addTarget(self, action: #selector(userSelectedGender(segmented:)),
                                     for: .valueChanged)
            cell.selectionStyle = .none
            return cell
        case 6: // units
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditSwitchTableViewCell",
                                                           for: indexPath) as? EditSwitchTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = "Units".localized
            cell.segmented.removeAllSegments()
            for (i, key) in UnitSelection.allCases.enumerated() {
                cell.segmented.insertSegment(withTitle: key.rawValue.capitalized.localized,
                                             at: i, animated: false)
            }
            UnitSelection.allCases.enumerated().forEach {
                if $0.element == userProfile.units {
                    cell.segmented.selectedSegmentIndex = $0.offset
                }
            }
            cell.segmented.addTarget(self,
                                     action: #selector(userSelectedUnits(segmented:)),
                                     for: .valueChanged)
            cell.selectionStyle = .none
            return cell
        case 7: // BMI
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPickerTableViewCell",
                                                           for: indexPath) as? EditPickerTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = "CalculatedBMI".localized
            //  cell.labelTitle.textColor = .lightGray
            cell.labelValue.text = userProfile.bmiDescription
            cell.labelValue.textColor = .lightGray
            cell.selectionStyle = .none
            return cell
        case 8:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "LabelTableViewCell",
                                                           for: indexPath) as? LabelTableViewCell else {
                return UITableViewCell()
            }
            cell.bmiLabel.text = bmiText
            cell.bmiLabel.textColor = .lightGray
            cell.selectionStyle = .none
            return cell
        case 9:
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPickerTableViewCell",
                                                           for: indexPath) as? EditPickerTableViewCell else {
                return UITableViewCell()
            }
            cell.labelTitle.text = "Logout".localized
            cell.labelValue.text = nil
            cell.selectionStyle = .none
            return cell
        default: // Height
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditPickerTableViewCell",
                                                           for: indexPath) as? EditPickerTableViewCell else {
                return UITableViewCell()
            }
            return cell
        }

    }

    @objc func userSelectedGender(segmented: UISegmentedControl) {
        //   navigationItem.rightBarButtonItem?.isEnabled = false
        GenderSelection.allCases.enumerated().forEach {
            if $0.offset == segmented.selectedSegmentIndex {
                userProfile?.gender = $0.element
            }
        }
    }

    @objc func userSelectedUnits(segmented: UISegmentedControl) {
        //   navigationItem.rightBarButtonItem?.isEnabled = false
        UnitSelection.allCases.enumerated().forEach {
            if $0.offset == segmented.selectedSegmentIndex {
                userProfile?.units = $0.element
            }
        }
        tableView.reloadData()
    }

}

extension EditProfileViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //   navigationItem.rightBarButtonItem?.isEnabled = true
        // print("indexPath.row", indexPath.row)
        //        guard let userProfile = userProfile else { return }

        switch indexPath.row {

        case 2: // Height
            view.endEditing(true)
            guard let userProfile = userProfile else { return }

            //         //   let vcc = FoodRecognitionViewController(nibName: "FoodRecognitionViewController",
            //                                                    bundle: self.bundleForModule)
            //
            //            guard let pickerView = self.bundlePod.loadNibNamed("PickerPopUpView",
            //                                                      owner: nil,
            //                                                      options: nil)?.first as? PickerPopUpView else {
            //                return
            //            }

            let nib = UINib(nibName: "PickerPopUpView", bundle: bundlePod)
            guard let pickerView = nib.instantiate(withOwner: self, options: nil).first as? PickerPopUpView else {
                return
            }
            let unitDescption = userProfile.units == .imperial ?  "Feet".localized : "Meter".localized
            pickerView.title = "Height".localized + " " + unitDescption
            pickerView.modelOneComp = userProfile.heightArrayForPicker[0]
            pickerView.modelTwoComp = userProfile.heightArrayForPicker[1]
            pickerView.startingOneComp = userProfile.heightInitialValueForPicker[0]
            pickerView.startingTwoComp = userProfile.heightInitialValueForPicker[1]
            pickerView.indexPath = indexPath
            pickerView.delegate = self
            animatePickerPopUp(viewtoAnimate: pickerView, toBeDisplayed: true)
        // Go to app delegate  and start again
        case 4:
            guard let userProfile = userProfile else { return }
            view.endEditing(true)
            // guard let userProfile = userProfile else { return }
            let nib = UINib(nibName: "PickerMacrosView", bundle: bundlePod)
            guard let pickerView = nib.instantiate(withOwner: self, options: nil).first as? PickerMacrosView
                 // ,let userProfile = userProfile
            else {
                return
            }
            let macros = Macros(caloriesTarget: userProfile.caloriesTarget,
                                carbsPercent: userProfile.carbsPercent,
                                proteinPercent: userProfile.proteinPercent,
                                fatPercent: userProfile.fatPercent)
            pickerView.modelMacros = macros
            pickerView.delegate = self
            animatePickerPopUp(viewtoAnimate: pickerView, toBeDisplayed: true)
        case 9:
            print("case 11")
            alertUser()
        default:
            view.endEditing(true)
        // print(indexPath.row)
        }
    }

    func alertUser() {
        #if APPMODULEFLAG
        let alert = UIAlertController(title: "Logout".localized + "?",
                                      message: "LogoutBody".localized,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Logout".localized,
                                      style: .destructive) { _ in
            AuthService.sharedInstance.removeUserCredentials()
            // self.navigationController?.popViewController(animated: true)
            let aPPdelegate = UIApplication.shared.delegate as! AppDelegate
            aPPdelegate.setRoot(viewId: "MainStoryboardID")
            // delegate.setRoot(viewId: customStartingViewID, withStoryBoard: "Welcome")
        })
        alert.addAction(UIAlertAction(title: "Cancel".localized,
                                      style: .default) {_ in
            self.tableView.reloadData()
        })
        present(alert, animated: true, completion: nil)
        #endif
    }

}

extension EditProfileViewController: PickerPopUpViewDelegate {

    // picker

    func pickerSelected(compOne: Int?, compTwo: Int?, indexPath: IndexPath?, myView: PickerPopUpView) {

        guard let comp1 = compOne else {
            animatePickerPopUp(viewtoAnimate: myView, toBeDisplayed: false)
            return
        }
        switch indexPath?.row {
        //        case 0:// age
        //            userProfile.age = comp1
        //            //        case 2:// Weigth
        //        //            modelUserProfile.weight = compOne
        case 2:// Height
            if let comp2 = compTwo {
                userProfile?.setHeightInMetersFor(compOne: comp1, compTwo: comp2)
            }
        default:
            break
        }
        animatePickerPopUp(viewtoAnimate: myView, toBeDisplayed: false)
    }

}

extension EditProfileViewController: PickerMacroViewDelegate {

    func pickerSelected(modelMacros: Macros?, myView: PickerMacrosView) {

         if let modelMacros = modelMacros {
            userProfile?.carbsPercent = modelMacros.carbsPercent
            userProfile?.proteinPercent = modelMacros.proteinPercent
            userProfile?.fatPercent = modelMacros.fatPercent
        }
        animatePickerPopUp(viewtoAnimate: myView, toBeDisplayed: false)
    }

}

extension EditProfileViewController {// Animations

    func animatePickerPopUp(viewtoAnimate: UIView, toBeDisplayed: Bool) {
        let screen = UIScreen.main.bounds
        let margin: CGFloat = 10.0
        let height: CGFloat = 340.0
        var startingFrame = CGRect(x: margin, y: screen.height,
                                   width: screen.width-2*margin, height: height)
        var endingFrame = CGRect(x: margin, y: screen.height/2-height/2,
                                 width: screen.width-2*margin, height: height)
        if !toBeDisplayed { // switch frames
            endingFrame = startingFrame
            startingFrame = viewtoAnimate.frame
            tableView.isUserInteractionEnabled = true
            self.tableView.reloadData()
        } else {
            tableView.isUserInteractionEnabled = false
        }
        viewtoAnimate.frame = startingFrame // startingFrame
        view.addSubview(viewtoAnimate)
        UIView.animateKeyframes(withDuration: 0.5, delay: 0,
                                options: .calculationModeLinear, animations: {
                                    viewtoAnimate.frame = endingFrame
                                }) { (_) in
            if !toBeDisplayed {
                viewtoAnimate.removeFromSuperview()
            }
        }
    }

}

extension EditProfileViewController: UITextFieldDelegate {

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // navigationItem.rightBarButtonItem?.isEnabled = false
        switch textField.tag {
        case 1...6: // Weight DailyCalories //Keyboard ToolBar
            let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 44)
            let kbToolBarView = UIToolbar.init(frame: frame )
            //            let title = UIBarButtonItem(title: "Weight"), style: .plain, target: nil, action: nil)
            let kbSpacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                           target: nil, action: nil)
            let bottonOk = UIBarButtonItem(title: "OK".localized,
                                           style: .plain,
                                           target: self,
                                           action: #selector(closeKeyBoard))
            kbToolBarView.items = [kbSpacer, bottonOk, kbSpacer]
            kbToolBarView.tintColor = .white
            kbToolBarView.barTintColor = UIColor(named: "CustomBase", in: bundlePod, compatibleWith: nil)
            textField.inputAccessoryView = kbToolBarView
            return true
        default:
            return true
        }

    }

    @objc func closeKeyBoard() {
        view.endEditing(true)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 2: // check if valid weight
            if let weight = textField.text, let _ = Double(weight) {
                textField.resignFirstResponder()
                return true
            } else {
                return false
            }
        case 3...6: // check if valid target
            if let target = textField.text, let _ = Double(target) {
                textField.resignFirstResponder()
                return true
            } else {
                return false
            }
        default:
            textField.resignFirstResponder()
            return true
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField, reason: UITextField.DidEndEditingReason) {

        guard var userProfile = userProfile else { return }
        switch textField.tag {
        case 1: // last name
            if let _weight = textField.text, let dWeight = Double(_weight) {
                switch userProfile.units {
                case .metric:
                    userProfile.weight = dWeight
                case .imperial:
                    userProfile.weight = dWeight/Conversion.lbsToKg.rawValue
                }
            }
        case 3: // Targt Calories
            if let calTarget = textField.text, let target = Double(calTarget) {
                userProfile.caloriesTarget = Int(target)
            }
//        case 4: // Targt protein
//            if let calTarget = textField.text, let target = Int(calTarget) {
//                userProfile.dailyProteinTarget = target
//            }
//        case 5: // Targt fat
//            if let calTarget = textField.text, let target = Int(calTarget) {
//                userProfile.dailyFatTarget = target
//            }
//        case 6: // Targt carb
//            if let calTarget = textField.text, let target = Int(calTarget) {
//                userProfile.dailyCarbsTarget = target
//            }
        default:
            print()
        }
        self.userProfile = userProfile
        tableView.reloadData()
    }
}

extension EditProfileViewController: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {

        print("slide to dismiss stopped")
        self.dismiss(animated: true, completion: nil)
    }
}

//        case 1: //Age
//            view.endEditing(true)
//            let pickerView = Bundle.main.loadNibNamed("PickerPopUpView", owner: nil, options: nil)?.first as! PickerPopUpView
//            pickerView.title = "Age".localized
//            pickerView.modelOneComp = Array(0...120).map {String($0)}
//            pickerView.startingOneComp = userProfile.age == nil ? 28 : userProfile.age
//            pickerView.indexPath = indexPath
//            pickerView.delegate = self
//            animatePickerPopUp(viewtoAnimate: pickerView, toBeDisplayed: true)
//            //        case 2: // Weight
//
//            //            view.endEditing(true)
//            //            let pickerView = Bundle.main.loadNibNamed("PickerPopUpView", owner: nil, options: nil)?.first as! PickerPopUpView
//            //            let unitDescption = modelUserProfile.units == .imperial ?  "Lbs") : "Kg".localized
//            //            pickerView.title = "Weight") + " " + unitDescption
//            //            pickerView.modelOneComp = Array(0...250)
//            //            //pickerView.startingOneComp = modelUserProfile.weight == 0 ? 150 : modelUserProfile.weight
//            //            pickerView.indexPath = indexPath
//            //            pickerView.delegate = self
//        //            animatePickerPopUp(viewtoAnimate: pickerView, toBeDisplayed: true)
//        case 1, 3:
//            if let cell = tableView.cellForRow(at: indexPath) as? EditTextTableViewCell {
//                cell.textValue.becomeFirstResponder()
//            }
//            return

// extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//
//    @objc func editPhoto() {
//        let alert = UIAlertController(title: "EditPhoto".localized, message: nil, preferredStyle: .actionSheet)
//        alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel) { (_) in
//            print("Cancel")
//        })
//        alert.addAction(UIAlertAction(title: "Camera".localized, style: .default, handler: { (_) in
//            self.openCamera()
//        }))
//
//        alert.addAction(UIAlertAction(title: "Gallery".localized, style: .default, handler: { (_) in
//            self.openGalery()
//        }))
//        self.present(alert, animated: true, completion: nil)
//    }
//
//    func openCamera() {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = UIImagePickerController.SourceType.camera
//            imagePicker.cameraDevice = .front
//            imagePicker.allowsEditing = true
//            self.present(imagePicker, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: "Warning", message: "You don't have camera", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func openGalery() {
//        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.photoLibrary) {
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.allowsEditing = true
//            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//            self.present(imagePicker, animated: true, completion: nil)
//        } else {
//            let alert = UIAlertController(title: "Warning", message: "You don't have permission to access gallery.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//        if let  selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
//            userProfile.saveImageToDisk(image: selectedImage)
//            tableView.reloadData()
//        }
//        picker.dismiss(animated: true, completion: nil)
//    }

// }

//        case 4: // Target Proterin
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextTableViewCell",
//                                                           for: indexPath) as? EditTextTableViewCell else {
//                return UITableViewCell()
//            }
//            cell.labelTitle.text = "DailyProtein".localized
//            cell.textValue.text = String(Int(userProfile.dailyProteinTarget))
//            cell.textValue.tag = indexPath.row
//            cell.textValue.delegate = self
//            cell.textValue.clearsOnBeginEditing = false
//            cell.selectionStyle = .none
//            return cell
//        case 5: // Target Proterin
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextTableViewCell",
//                                                           for: indexPath) as? EditTextTableViewCell else {
//                return UITableViewCell()
//            }
//            cell.labelTitle.text = "DailyFat".localized
//            cell.textValue.text = String(Int(userProfile.dailyFatTaget))
//            cell.textValue.tag = indexPath.row
//            cell.textValue.delegate = self
//            cell.textValue.clearsOnBeginEditing = false
//            cell.selectionStyle = .none
//            return cell
//        case 6: // Target Proterin
//            guard let cell = tableView.dequeueReusableCell(withIdentifier: "EditTextTableViewCell",
//                                                           for: indexPath) as? EditTextTableViewCell else {
//                return UITableViewCell()
//            }
//            cell.labelTitle.text = "DailyCarbs".localized
//            cell.textValue.text = String(Int(userProfile.dailyCarbsTarget))
//            cell.textValue.tag = indexPath.row
//            cell.textValue.delegate = self
//            cell.textValue.clearsOnBeginEditing = false
//            cell.selectionStyle = .none
//            return cell
