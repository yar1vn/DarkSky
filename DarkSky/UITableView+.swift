//
//  UITableView+.swift
//  DarkSky
//
//  Created by Yariv Nissim on 12/12/18.
//  Copyright © 2018 Yariv. All rights reserved.
//

import UIKit

extension UITableView {
    func indexPath(for cell: Any?) -> IndexPath? {
        guard let cell = cell as? UITableViewCell,
            let indexPath = indexPath(for: cell) else {
                return nil
        }
        return indexPath
    }
}
