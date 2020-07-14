//
//  SettingsViewController.swift
//  MyDiary
//
//  Created by Jinwoo Kim on 28/03/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    
    // MARK:- Properties
    
    var viewModel: SettingsViewModel!
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.title = "설정"
        self.tableView = UITableView(frame: .zero, style: .grouped)
        self.tableView.register(SettingsCell.self)
    }
    
    deinit {
        print("Settings Controller \(#function)")
    }
}

// MARK: - Extensions

extension SettingsViewController {
    
    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int)
        -> Int
    {
        return self.viewModel.numberOfRows(in: section)
    }
    
    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath)
        -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(cellType: SettingsCell.self, for: indexPath)
        cell.viewModel = self.viewModel.settingsCellViewModel(for: indexPath)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.viewModel.numberOfSections
    }
    
    override func tableView(
        _ tableView: UITableView,
        titleForHeaderInSection section: Int)
        -> String?
    {
        return self.viewModel.headerTitle(of: section)
    }
    
    override func tableView(
        _ tableView: UITableView,
        didSelectRowAt indexPath: IndexPath)
    {
        self.viewModel.selectOption(for: indexPath)
        tableView.reloadData()
    }
}
