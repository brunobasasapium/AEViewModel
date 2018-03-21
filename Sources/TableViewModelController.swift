/**
 *  https://github.com/tadija/AEViewModel
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import UIKit

open class TableViewModelController: UITableViewController {
    
    // MARK: Properties
    
    open var model: DataSource = BasicDataSource() {
        didSet {
            reload()
        }
    }
    
    open var isAutomaticReloadEnabled = true
    
    // MARK: Init
    
    public convenience init(style: UITableViewStyle, model: DataSource) {
        self.init(style: style)
        self.model = model
    }
    
    public convenience init() {
        self.init(style: .grouped)
    }
    
    // MARK: Lifecycle
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        registerCells()
    }
    
    // MARK: Abstract
    
    open func cell(forIdentifier identifier: String) -> TableCell {
        return .basic
    }
    
    open func configureCell(_ cell: UITableViewCell & TableViewModelCell, at indexPath: IndexPath) {
        cell.update(with: item(at: indexPath))
    }
    
    // MARK: API
    
    public func section(at index: Int) -> Section {
        let section = model.sections[index]
        return section
    }
    
    public func item(at indexPath: IndexPath) -> Item {
        let item = model.sections[indexPath.section].items[indexPath.item]
        return item
    }
    
    public func item(from cell: TableViewModelCell) -> Item? {
        guard
            let tableViewCell = cell as? UITableViewCell,
            let indexPath = tableView.indexPath(for: tableViewCell)
        else { return nil }
        return item(at: indexPath)
    }
    
    public func pushTable(from item: Item, in tvmc: TableViewModelController) {
        /// - TODO: check later
//        if let basicViewModel = item.model as? BasicViewModel, let child = basicViewModel.child {
//            tvmc.model = child
//            navigationController?.pushViewController(tvmc, animated: true)
//        }
    }
    
    public func nextIndexPath(from indexPath: IndexPath) -> IndexPath? {
        var newIndexPath = IndexPath(row: indexPath.row + 1, section: indexPath.section)
        if newIndexPath.row >= tableView(tableView, numberOfRowsInSection: indexPath.section) {
            let newSection = indexPath.section + 1
            newIndexPath = IndexPath(row: 0, section: newSection)
            if newSection >= numberOfSections(in: tableView) {
                return nil
            }
        }
        return newIndexPath
    }
    
    public func previousIndexPath(from indexPath: IndexPath) -> IndexPath? {
        var newIndexPath = IndexPath(row: indexPath.row - 1, section: indexPath.section)
        if newIndexPath.row < 0 {
            let newSection = indexPath.section - 1
            if newSection < 0 {
                return nil
            }
            let maxRow = tableView(tableView, numberOfRowsInSection: newSection) - 1
            newIndexPath = IndexPath(row: maxRow, section: newSection)
        }
        return newIndexPath
    }
    
    // MARK: Helpers
    
    private func reload() {
        if Thread.isMainThread {
            registerCellsAndReloadDataIfNeeded()
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.registerCellsAndReloadDataIfNeeded()
            }
        }
    }
    
    private func registerCellsAndReloadDataIfNeeded() {
        registerCells()
        if isAutomaticReloadEnabled {
            tableView.reloadData()
        }
    }
    
    private func registerCells() {
        var uniqueIdentifiers: Set<String> = Set<String>()
        model.sections.forEach { section in
            let sectionIdentifiers: [String] = section.items.flatMap({ $0.identifier })
            uniqueIdentifiers.formUnion(sectionIdentifiers)
        }
        uniqueIdentifiers.forEach { identifier in
            registerCell(with: identifier)
        }
    }
    
    private func registerCell(with identifier: String) {
        switch cell(forIdentifier: identifier) {
        case .basic:
            tableView.register(TableCellBasic.self, forCellReuseIdentifier: identifier)
        case .subtitle:
            tableView.register(TableCellSubtitle.self, forCellReuseIdentifier: identifier)
        case .leftDetail:
            tableView.register(TableCellLeftDetail.self, forCellReuseIdentifier: identifier)
        case .rightDetail:
            tableView.register(TableCellRightDetail.self, forCellReuseIdentifier: identifier)
        case .button:
            tableView.register(TableCellButton.self, forCellReuseIdentifier: identifier)
        case .toggleBasic:
            tableView.register(TableCellToggleBasic.self, forCellReuseIdentifier: identifier)
        case .toggleSubtitle:
            tableView.register(TableCellToggleSubtitle.self, forCellReuseIdentifier: identifier)
        case .textInput:
            tableView.register(TableCellTextInput.self, forCellReuseIdentifier: identifier)
        case .customClass(let cellClass):
            tableView.register(cellClass, forCellReuseIdentifier: identifier)
        case .customNib(let cellNib):
            tableView.register(cellNib, forCellReuseIdentifier: identifier)
        }
    }
    
}

// MARK: - UITableViewControllerDataSource

extension TableViewModelController {
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].items.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = item(at: indexPath).identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        if let cell = cell as? UITableViewCell & TableViewModelCell {
            configureCell(cell, at: indexPath)
        }
        return cell
    }
    
}

// MARK: - UITableViewControllerDelegate

extension TableViewModelController {
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard
            let cell = tableView.cellForRow(at: indexPath),
            let tableViewModelCell = cell as? TableViewModelCell
        else { return }
        
        if cell.selectionStyle != .none {
            tableViewModelCell.action(cell)
        }
    }
    
}
