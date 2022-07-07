//
//  MenuItemsViewController.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

import UIKit

class MenuItemsViewController: UIViewController {
    let menuController = MenuController.shared

    var selectedCategory: String?
    var menuItems = [MenuItem]()
    var imageLoadTasks = [IndexPath: Task<Void, Never>]()

    private var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        title = selectedCategory?.capitalized

        Task {
            do {
                guard let selectedCategory = selectedCategory else { return }
                let fetchedMenuItems = try await menuController.fetchMenuItems(forCategory: selectedCategory)
                configureViews(withMenuItems: fetchedMenuItems)
                layoutSubviews()
            } catch {
                displayError(error, title: "Unable to fetch menu items for category: \(selectedCategory!)")
            }
        }
    }

    override func viewDidDisappear(_ animated: Bool) {
        imageLoadTasks.forEach { _, task in task.cancel() }
    }

    func configureViews(withMenuItems menuItems: [MenuItem]) {
        self.menuItems = menuItems
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: "MenuItemCell")
    }

    func layoutSubviews() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func displayError(_ error: Error, title: String) {
        guard viewIfLoaded?.window != nil else { return }

        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

extension MenuItemsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath)
        configureCell(cell, forMenuItemAt: indexPath)
        return cell
    }

    func configureCell(_ cell: UITableViewCell, forMenuItemAt indexPath: IndexPath) {
        guard let cell = cell as? MenuItemTableViewCell else { return }

        let menuItem = menuItems[indexPath.row]

        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil
        cell.accessoryType = .disclosureIndicator

        imageLoadTasks[indexPath] = Task {
            if let image = try? await menuController.fetchImage(fromURL: menuItem.imageUrl) {
                if let currentIndexPath = self.tableView.indexPath(for: cell),
                   currentIndexPath == indexPath {
                    cell.image = image
                }
            }
            imageLoadTasks[indexPath] = nil
        }
    }
}

extension MenuItemsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let selectedMenuItem = menuItems[indexPath.row]
        let detailViewController = DetailViewController()

        detailViewController.menuItem = selectedMenuItem
        navigationController?.pushViewController(detailViewController, animated: true)
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        imageLoadTasks[indexPath]?.cancel()
    }
}
