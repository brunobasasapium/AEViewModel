/**
 *  https://github.com/tadija/AEViewModel
 *  Copyright (c) Marko Tadić 2017-2018
 *  Licensed under the MIT license. See LICENSE file.
 */

import AEViewModel
import SafariServices

final class GithubTVMC: TableViewModelController {

    // MARK: Properties

    var github: GithubViewModel? {
        return viewModel as? GithubViewModel
    }

    // MARK: Init
    
    public convenience init() {
        self.init(style: .plain)
    }
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel = GithubViewModel()

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 150

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
    }
    
    private var initialAppear = true

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if initialAppear {
            initialAppear = false
            performManualRefresh()
        }
    }
    
    // MARK: TableViewModelControllerDelegate
    
    override func cellType(forIdentifier identifier: String) -> TableCellType {
        return .customNib(GithubRepoCell.self)
    }

    override func action(for cell: TableViewModelCell, at indexPath: IndexPath, sender: Any) {
        if let repo = viewModel.model(at: indexPath) as? Repo, let url = URL(string: repo.url) {
            let browser = SFSafariViewController(url: url)
            browser.title = title
            present(browser, animated: true, completion: nil)
        }
    }
    
    // MARK: Helpers

    private func performManualRefresh() {
        if let refreshControl = refreshControl {
            tableView.contentOffset = CGPoint(x: 0, y: -refreshControl.frame.size.height)
            refreshControl.beginRefreshing()
            refresh(refreshControl)
        }
    }
    
    @objc
    private func refresh(_ sender: UIRefreshControl) {
        github?.reload() { [weak self] (viewModel) in
            sender.endRefreshing()
            self?.viewModel = viewModel
        }
    }
    
}
