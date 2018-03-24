/**
 *  https://github.com/tadija/AEViewModel
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit

open class CollectionViewModelController: UICollectionViewController {
    
    // MARK: Properties

    open var isAutomaticReloadEnabled = true

    open var dataSource: DataSource = BasicDataSource() {
        didSet {
            if isAutomaticReloadEnabled {
                reload()
            }
        }
    }
    
    // MARK: Init

    public convenience init() {
        self.init(dataSource: BasicDataSource())
    }
    
    public convenience init(dataSource: DataSource, layout: UICollectionViewLayout = UICollectionViewFlowLayout()) {
        self.init(collectionViewLayout: layout)
        self.dataSource = dataSource
    }
    
    // MARK: Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        reload()
    }

    // MARK: CollectionViewModelControllerDelegate

    open func cellType(forIdentifier identifier: String) -> CollectionCellType {
        return .basic
    }

    open func update(_ cell: CollectionViewModelCell, at indexPath: IndexPath) {
        let item = dataSource.item(at: indexPath)
        cell.update(with: item)
        cell.callback = { [weak self] sender in
            self?.action(for: cell, at: indexPath)
        }
    }

    open func action(for cell: CollectionViewModelCell, at indexPath: IndexPath) {}
    
    // MARK: Helpers
    
    private func reload() {
        if Thread.isMainThread {
            performReload()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.performReload()
            }
        }
    }

    private func performReload() {
        if let title = dataSource.title {
            self.title = title
        }
        registerCells()
        collectionView?.reloadData()
    }
    
    private func registerCells() {
        dataSource.uniqueIdentifiers.forEach { id in
            registerCell(with: id)
        }
    }
    
    private func registerCell(with identifier: String) {
        switch cellType(forIdentifier: identifier) {
        case .basic:
            collectionView?.register(CollectionCellBasic.self, forCellWithReuseIdentifier: identifier)
        case .customClass(let cellClass):
            collectionView?.register(cellClass, forCellWithReuseIdentifier: identifier)
        case .customNib(let cellClass):
            collectionView?.register(cellClass.nib, forCellWithReuseIdentifier: identifier)
        }
    }
    
}

// MARK: - UICollectionViewControllerDataSource

extension CollectionViewModelController {
    
    open override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.sections.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.sections[section].items.count
    }
    
    open override func collectionView(_ collectionView: UICollectionView,
                                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let id = dataSource.identifier(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: id, for: indexPath)
        if let cell = cell as? CollectionViewModelCell {
            update(cell, at: indexPath)
        }
        return cell
    }
    
}

// MARK: - UICollectionViewControllerDelegate

extension CollectionViewModelController {
    
    open override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? CollectionViewModelCell else {
            return
        }
        action(for: cell, at: indexPath)
    }
    
}
