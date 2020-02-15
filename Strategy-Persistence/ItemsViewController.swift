//
//  ItemsViewController.swift
//  Strategy-Persistence
//
//  Created by Zafar on 2/14/20.
//  Copyright © 2020 Zafar. All rights reserved.
//

import UIKit

class ItemsViewController: UIViewController {

    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
       
        items = persistenceStrategy.getItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavItem()
    }
    
    // MARK: - Actions
    @objc func persistenceTypeChanged(sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex  {
        case 0:
            persistenceStrategy = CoreDataStrategy()
            items = persistenceStrategy.getItems()
            tableView.reloadData()
        case 1:
            persistenceStrategy = RealmStrategy()
            items = persistenceStrategy.getItems()
            tableView.reloadData()
        default: break
        }
    }
    
    @objc func addButtonTapped() {
        let alert = UIAlertController(title: "Add an item", message: nil, preferredStyle: .alert)
        
        let add = UIAlertAction(title: "Add", style: .default) { _ in
            if let title = alert.textFields![0].text {
                
                if let newItem = self.persistenceStrategy.addItem(title: title) {
                self.items.append(newItem)
                self.tableView.reloadData()
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Item title"
        }
        
        alert.addAction(add)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func presentAlert(with title: String,
                      and id: String) {
        let alert = UIAlertController(title: "Edit an item", message: nil, preferredStyle: .alert)
        
        let edit = UIAlertAction(title: "Edit", style: .default) { _ in
            if let newTitle = alert.textFields![0].text {
                
                self.persistenceStrategy.editItem(id: id, newTitle: newTitle) {
                    let itemToEdit = self.items
                        .filter { $0.id == id }
                        .first!
                    
                    itemToEdit.title = newTitle
                    self.tableView.reloadData()
                }
            }
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Item new title"
            textField.text = title
        }
        
        alert.addAction(edit)
        alert.addAction(cancel)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: - Properties
    var persistenceStrategy: PersistenceStrategy = CoreDataStrategy()
    private var items = [Item]()
    
    lazy var persistenceTypeSegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl(items: ["Core Data", "Realm"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(persistenceTypeChanged), for: .valueChanged)
        return control
    }()
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.rowHeight = 70
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        tableView
            .translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()

    lazy var addButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addButtonTapped))
        return item
    }()

}

// MARK: - UITableView Delegate & Data Source
extension ItemsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return persistenceStrategy.title
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let itemToEdit = items[indexPath.row]
        self.presentAlert(with: itemToEdit.title, and: itemToEdit.id)
        self.tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            persistenceStrategy.deleteItem(id: items[indexPath.row].id) {
                self.items.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

// MARK: - UI Setup
extension ItemsViewController {
    private func setupUI() {
        if #available(iOS 13.0, *) {
            overrideUserInterfaceStyle = .light
        }
        self.view.backgroundColor = .white
        
        self.view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.widthAnchor
                .constraint(equalTo: self.view.widthAnchor),
            tableView.heightAnchor
                .constraint(equalTo: self.view.heightAnchor)
        ])
    }
    
    private func setupNavItem() {
        self.navigationItem.title = "Items"
        self.navigationItem.rightBarButtonItem = addButtonItem
        self.navigationItem.titleView = persistenceTypeSegmentedControl
    }
}
