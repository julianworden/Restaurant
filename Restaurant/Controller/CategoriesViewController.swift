//
//  ViewController.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

import UIKit

class CategoriesViewController: UIViewController {
    let menuController = MenuController.shared
    var categories = [String]()

    private var tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        Task {
            do {
                let categories = try await menuController.fetchCategories()
                configureViews(withCategories: categories)
                layoutSubviews()
            } catch {
                displayError(error, title: "Failed to fetch categories")
            }
        }
    }

    func configureViews(withCategories categories: [String]) {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .always
        title = "Menu"

        self.categories = categories
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CategoryCell")
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

extension CategoriesViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "CategoryCell")

        tableView.dequeueReusableCell(withIdentifier: "CategoryCell", for: indexPath)
        configureCell(cell, forCategoryAt: indexPath)
        return cell
    }

    func configureCell(_ cell: UITableViewCell, forCategoryAt indexPath: IndexPath) {
        let category = categories[indexPath.row]

        var content = cell.defaultContentConfiguration()
        content.text = category.capitalized
        cell.contentConfiguration = content
        cell.accessoryType = .disclosureIndicator
    }

}

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let menuItemsViewController = MenuItemsViewController()
        menuItemsViewController.selectedCategory = categories[indexPath.row]
        navigationController?.pushViewController(menuItemsViewController, animated: true)
    }
}
