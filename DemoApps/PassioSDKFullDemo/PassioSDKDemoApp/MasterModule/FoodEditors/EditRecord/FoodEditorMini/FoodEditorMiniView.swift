//
//  FoodEditorMiniView
//  PassioPassport
//
//  Created by zvika on 3/25/19.
//  Copyright © 2023 Passiolife Inc. All rights reserved.
//

import UIKit
#if canImport(PassioNutritionAISDK)
import PassioNutritionAISDK
#endif

class FoodEditorMiniView: FoodEditorView {

    override func awakeFromNib() {
        super.awakeFromNib()
        buttonAddToFavorites.setTitle("Favorites", for: .normal)
        buttonSave.setTitle( "Log", for: .normal)
    }

    override func getCellNameFor(indexPath: IndexPath) -> CellNameFoodEditor {
       // print("getCellNameFor(indexPath =\(indexPath.row)" )
        switch indexPath.row {
        case 0:
            return .foodHeaderMiniTableViewCell
        case 1:
            return .amountSliderMiniTableViewCell
        case 2:
            return .amountQuickMiniTableViewCell
        case 3:
            if showAlternativesRow {
                if Custom.useNutritionBrowser {
                    return .alternativeBrowserTableViewCell
                } else {
                    return .alternativesMiniTableViewCell
                }
            } else {
                return .mealSelectionTableViewCell
            }
        case 4:
            return .mealSelectionTableViewCell
        default:
            return .openFoodTableViewCell
        }
    }

}

extension FoodEditorMiniView {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let foodRecord = foodRecord else { return 0 }
        let openFood = foodRecord.isOpenFood ? 1 : 0
        return rowsBeforeIngrediants + openFood
    }
}
