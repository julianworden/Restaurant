//
//  OrderConfirmationViewController.swift
//  Restaurant
//
//  Created by Julian Worden on 7/6/22.
//

import UIKit

class OrderConfirmationViewController: UIViewController {

    var minutesToPrepareOrder: Int?
    let menuController = MenuController.shared

    lazy var contentStack = UIStackView(arrangedSubviews: [confirmationLabel, dismissButton])
    let confirmationLabel = UILabel()
    let dismissButton = UIButton(configuration: .plain())

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews()
        layoutViews()
    }

    func configureViews() {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never
        title = "Confirmation"

        contentStack.axis = .vertical
        contentStack.spacing = 10
        contentStack.distribution = .fill
        contentStack.alignment = .center

        if let minutesToPrepareOrder = minutesToPrepareOrder {
            confirmationLabel.text = "Thank you for your order! It will be ready in \(minutesToPrepareOrder) minutes."
        } else {
            confirmationLabel.text = "Thank you for your order! It will be ready soon."
        }

        confirmationLabel.textColor = .black
        confirmationLabel.font = .systemFont(ofSize: 20)
        confirmationLabel.numberOfLines = 0
        confirmationLabel.textAlignment = .center

        dismissButton.setTitle("Dismiss", for: .normal)
        dismissButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
    }

    func layoutViews() {
        view.addSubview(contentStack)

        contentStack.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            contentStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            contentStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    @objc func dismissViewController() {
        menuController.order.menuItems.removeAll()
        dismiss(animated: true)
    }

    func displayError(_ error: Error, title: String) {
        guard viewIfLoaded?.window != nil else { return }

        let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))

        present(alert, animated: true, completion: nil)
    }
}
