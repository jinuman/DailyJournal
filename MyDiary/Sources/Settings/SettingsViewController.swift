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
    let settingsCellId = "settingsCellId"
    var viewModel: SettingsViewModel!
    
    // MARK:- Life Cycle methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "설정"
        tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(SettingsCell.self, forCellReuseIdentifier: settingsCellId)
    }
    
    deinit {
        print("Settings Controller \(#function)")
    }
}

// MARK:- Regarding tableView methods
extension SettingsViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows(in: section)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: settingsCellId) as? SettingsCell else {
            fatalError("Settings cell is bad")
        }
        
        cell.viewModel = viewModel.settingsCellViewModel(for: indexPath)
        return cell
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.numberOfSections
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.headerTitle(of: section)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectOption(for: indexPath)
        tableView.reloadData()
    }
}
