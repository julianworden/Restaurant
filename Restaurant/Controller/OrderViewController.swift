//
//  MyOrderViewController.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

import UIKit

class OrderViewController: UIViewController {
    let menuController = MenuController.shared

    private var tableView = UITableView()
    private var submitButton = UIBarButtonItem()

    var imageLoadTasks = [IndexPath: Task<Void, Never>]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        layoutViews()
        addNotificationObserver()
    }

    func configureViews() {
        view.backgroundColor = .white

        title = "My Order"
        navigationItem.largeTitleDisplayMode = .always
        navigationItem.leftBarButtonItem = editButtonItem

        submitButton.title = "Submit"
        submitButton.style = .plain
        submitButton.target = self
        submitButton.action = #selector(submitButtonTapped)
        navigationItem.rightBarButtonItem = submitButton

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(MenuItemTableViewCell.self, forCellReuseIdentifier: "OrderItemCell")
    }

    func layoutViews() {
        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }

    func addNotificationObserver() {
        NotificationCenter.default.addObserver(
            tableView,
            selector: #selector(UITableView.reloadData),
            name: MenuController.orderUpdatedNotification,
            object: nil
        )
    }

    @objc func submitButtonTapped() {
        let orderTotal = menuController.order.menuItems.reduce(0, { return $0 + $1.price })
        let formattedTotal = orderTotal.formatted(.currency(code: Locale.current.currencyCode ?? "usd"))

        let confirmationAlert = UIAlertController(
            title: "Confirm Order.",
            message: "Your order total is \(formattedTotal)",
            preferredStyle: .actionSheet
        )
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Continue", style: .default, handler: uploadOrder)
        confirmationAlert.addAction(cancelAction)
        confirmationAlert.addAction(continueAction)
        present(confirmationAlert, animated: true, completion: nil)
    }

    func uploadOrder(alert: UIAlertAction? = nil) {
        let menuIds = menuController.order.menuItems.map { $0.id }

        Task {
            do {
                let minutesToPrepareOrder = try await menuController.submitOrder(forMenuIDs: menuIds)

                let orderConfirmationViewController = OrderConfirmationViewController()
                orderConfirmationViewController.minutesToPrepareOrder = minutesToPrepareOrder
                orderConfirmationViewController.isModalInPresentation = true
                present(orderConfirmationViewController, animated: true, completion: nil)
            } catch {
                displayError(error, title: "Order Submission Failed")
            }
        }
    }

    func displayError(_ error: Error, title: String) {
        guard viewIfLoaded?.window != nil else { return }

        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}

extension OrderViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuController.order.menuItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderItemCell", for: indexPath)
        configureCell(cell, forItemAt: indexPath)
        return cell
    }

    func configureCell(_ cell: UITableViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? MenuItemTableViewCell else { return }

        let menuItem = menuController.order.menuItems[indexPath.row]

        cell.itemName = menuItem.name
        cell.price = menuItem.price
        cell.image = nil

        imageLoadTasks[indexPath] = Task {
            if let image = try? await menuController.fetchImage(fromURL: menuItem.imageUrl) {
                if let currentIndexPosition = self.tableView.indexPath(for: cell),
                   currentIndexPosition == indexPath {
                    cell.image = image
                }
            }
            imageLoadTasks[indexPath] = nil
        }
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            menuController.order.menuItems.remove(at: indexPath.row)
        }
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: true)
        tableView.setEditing(true, animated: true)
    }
}

extension OrderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
