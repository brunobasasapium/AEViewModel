//
//  ExampleTVMC.swift
//  TableExample
//
//  Created by Marko Tadić on 6/3/17.
//  Copyright © 2017 AE. All rights reserved.
//

import UIKit
import Table

final class ExampleTVMC: TableViewModelController {
    
    typealias General = ExampleTable.General
    
    // MARK: Override
    
    override func customInit() {
        table = ExampleTable()
    }
    
    override func cellUI(forIdentifier identifier: String) -> Cell.UI {
        return .subtitle
    }
    
    override func handleEvent(_ event: UIControlEvents, with item: Item, sender: Any) {
        switch item.identifier {
        case General.Form.identifier:
            pushTable(from: item, in: FormTVMC())
        case General.Settings.identifier:
            pushTable(from: item, in: SettingsTVMC())
        default:
            break
        }
    }
    
}
