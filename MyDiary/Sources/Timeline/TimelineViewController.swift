//
//  TimelineViewController.swift
//  MyDiary
//
//  Created by Jinwoo Kim on 27/03/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

class TimelineViewController: UITableViewController {
    
    // MARK: - Properties
    
    private(set) var viewModel: TimelineViewModel
    
    private let cellId = "timelineCellId"
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Initializing
    
    required init(viewModel: TimelineViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.configure(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.configureTableView()
        self.configureNavigationItems()
        self.configureSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.navigationItem.hidesSearchBarWhenScrolling = false
//        self.searchController.searchBar.becomeFirstResponder()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if self.searchController.isActive {
            self.viewModel.searchText = nil
            self.searchController.isActive = false
        }
    }
    
    // MARK: - Binding
    
    private func configure(viewModel: TimelineViewModel) {
        
    }
    
    // MARK: - Methods
    
    private func configureTableView() {
        self.tableView.register(
            TimelineCell.self,
            forCellReuseIdentifier: cellId
        )
        self.tableView.allowsSelection = true
        self.tableView.isUserInteractionEnabled = true
    }
    
    private func configureNavigationItems() {
        self.navigationItem.title = "타임라인"
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(handleAdd)
        )
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: R.image.settings_black(),
            style: .plain,
            target: self,
            action: #selector(showSettings)
        )
    }
    
    private func configureSearchController() {
        self.definesPresentationContext = true
        
        self.searchController.searchBar.placeholder = "검색어로 일기를 찾아보세요.."
        self.searchController.searchBar.tintColor = .black
        self.searchController.searchBar.autocapitalizationType = .none
        self.searchController.obscuresBackgroundDuringPresentation = false
        self.searchController.searchResultsUpdater = self
        self.searchController.hidesNavigationBarDuringPresentation = true
        
        self.navigationItem.searchController = self.searchController
    }
    
    // MARK:- Handling methods
    @objc private func handleAdd() {
        let diaryViewController = DiaryViewController(viewModel: viewModel.newDiaryViewModel)
        self.navigationController?.pushViewController(diaryViewController, animated: true)
    }
    
    @objc private func showSettings() {
        let settingsController = SettingsViewController()
        settingsController.viewModel = viewModel.settingsViewModel
        
        let backItem = UIBarButtonItem()
        backItem.title = "뒤로"
        self.navigationItem.backBarButtonItem = backItem
        
        self.navigationController?.pushViewController(settingsController, animated: true)
    }
}

// MARK:- Regarding tableView methods
extension TimelineViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as? TimelineCell
            else {
                fatalError("Timeline cell is bad")
        }
        cell.viewModel = viewModel.timelineCellViewModel(for: indexPath)
        return cell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.headerTitle(of: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
        
        let diaryViewModel = viewModel.diaryViewModel(for: selectedIndexPath)
        let diaryViewController = DiaryViewController(viewModel: diaryViewModel) // env 주입
        self.navigationController?.pushViewController(diaryViewController, animated: true)
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard self.searchController.isActive == false else {
            return UISwipeActionsConfiguration(actions: [])
        }

        let removeAction = UIContextualAction(style: .normal, title:  nil) { [weak self] (action: UIContextualAction, view: UIView, success: (Bool) -> Void) in
            
            guard let self = self else { return }
            
            let isLastDiaryInSection: Bool = self.viewModel.numberOfRows(in: indexPath.section) == 1
            self.viewModel.removeDiary(at: indexPath)
            
            UIView.animate(withDuration: 0.3) {
                tableView.beginUpdates()
                if isLastDiaryInSection {
                    tableView.deleteSections(IndexSet.init(integer: indexPath.section), with: .automatic)
                } else {
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                }
                tableView.endUpdates()
            }
            success(true)
        }
        
        removeAction.image = R.image.delete_white()
        removeAction.backgroundColor = .red
        
        return UISwipeActionsConfiguration(actions: [removeAction])
    }
}

// MARK:- Regarding UISearchResultsUpdating methods
extension TimelineViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        
        self.viewModel.searchText = searchText
        self.tableView.reloadData()
    }
}
