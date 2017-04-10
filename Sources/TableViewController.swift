import UIKit

public protocol TableViewControllerDelegate: class {
    func cellType(forIdentifier identifier: String) -> TableModelCell.Type
}

open class TableViewController: UITableViewController {
    
    let model: TableModel
    
    public weak var delegate: TableViewControllerDelegate?
    
    public init(model: TableModel, style: UITableViewStyle = .grouped, delegate: TableViewControllerDelegate) {
        self.model = model
        self.delegate = delegate
        
        super.init(style: style)
        
        self.title = model.data?["title"] as? String
        registerCells()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func registerCells() {
        model.sections.forEach { section in
            section.items.forEach { item in
                /// - TODO: optimize this logic
                registerCell(with: item)
            }
        }
    }
    
    private func registerCell(with item: Item) {
        if let cellType = delegate?.cellType(forIdentifier: item.identifier) {
            /// - TODO: handle registering cell from nib
            tableView.register(cellType.self, forCellReuseIdentifier: item.identifier)
        } else {
            tableView.register(UITableViewCell.self, forCellReuseIdentifier: item.identifier)
        }
    }
    
}

extension TableViewController {
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return model.sections.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return model.sections[section].items.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = model.sections[indexPath.section].items[indexPath.item]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: item.identifier, for: indexPath)
        
        if let cell = cell as? TableModelCell {
            cell.configure(with: item)
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return model.sections[section].data?["header-title"] as? String
    }
}
