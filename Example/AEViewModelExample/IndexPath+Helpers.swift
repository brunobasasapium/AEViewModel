/**
 *  https://github.com/tadija/AEViewModel
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit

extension IndexPath {

    public func next(in tableView: UITableView) -> IndexPath? {
        var newIndexPath = IndexPath(row: row + 1, section: section)
        if newIndexPath.row >= tableView.numberOfRows(inSection: section) {
            let newSection = section + 1
            newIndexPath = IndexPath(row: 0, section: newSection)
            if newSection >= tableView.numberOfSections {
                return nil
            }
        }
        return newIndexPath
    }

    public func previous(in tableView: UITableView) -> IndexPath? {
        var newIndexPath = IndexPath(row: row - 1, section: section)
        if newIndexPath.row < 0 {
            let newSection = section - 1
            if newSection < 0 {
                return nil
            }
            let maxRow = tableView.numberOfRows(inSection: newSection) - 1
            newIndexPath = IndexPath(row: maxRow, section: newSection)
        }
        return newIndexPath
    }

    public func next(in collectionView: UICollectionView?) -> IndexPath? {
        guard let cv = collectionView else {
            return nil
        }
        var newIndexPath = IndexPath(row: row + 1, section: section)
        if newIndexPath.row >= cv.numberOfItems(inSection: section) {
            let newSection = section + 1
            newIndexPath = IndexPath(item: 0, section: newSection)
            if newSection >= cv.numberOfSections {
                return nil
            }
        }
        return newIndexPath
    }

    public func previous(in collectionView: UICollectionView?) -> IndexPath? {
        guard let cv = collectionView else {
            return nil
        }
        var newIndexPath = IndexPath(row: row - 1, section: section)
        if newIndexPath.row < 0 {
            let newSection = section - 1
            if newSection < 0 {
                return nil
            }
            let maxRow = cv.numberOfItems(inSection: newSection) - 1
            newIndexPath = IndexPath(item: maxRow, section: newSection)
        }
        return newIndexPath
    }

}
