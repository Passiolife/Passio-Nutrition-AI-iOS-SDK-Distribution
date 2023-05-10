//
//  FoodEditorLegacyView
//  PassioPassport
//
//  Created by zvika on 3/25/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class FoodEditorMicroView: FoodEditorView {

    override func getCellNameFor(indexPath: IndexPath) -> CellNameFoodEditor {
        switch indexPath.row {
        case 0:
            return .foodHeaderMicroTableViewCell
        default:
            if Custom.useNutritionBrowser {
                return .alternativeBrowserTableViewCell
            } else {
                return isMicroAlternatives ? .alternativesMicroTableViewCell :  .alternativesMiniTableViewCell
            }

        }
    }

}

extension FoodEditorMicroView {//: UITableViewDataSource {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        showAlternativesRow ? 2 : 1
    }
}

extension FoodEditorMicroView {  // }: UITableViewDelegate {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0, let foodRecord = foodRecord {
            delegate?.userSelected(foodRecord: foodRecord)
        }
    }
}

extension FoodEditorMicroView { // UIScrollView

    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
//        guard let foodRecord = foodRecord else { return }
//        // stopping the recognition when user scroll alternatives
//        if scrollView.tag == 0 {
//            _ = connector.updateRecord(foodRecord: foodRecord, isNew: true)
//            delegate?.addFoodToLog(foodRecord: foodRecord)
//        } else if scrollView.tag == IndexForCollections.alternatives.rawValue {
        if foodRecord != nil {
            delegate?.foodEditorRequest(pauseRecognition: true)
        }
//        }
    }

}
