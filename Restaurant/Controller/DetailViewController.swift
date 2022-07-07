//
//  DetailViewController.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

import UIKit

class DetailViewController: UIViewController {
    var menuItem: MenuItem!
    let menuController = MenuController.shared

    private lazy var foodInfoStack = UIStackView(
        arrangedSubviews: [imageView, itemNameAndPriceStack, foodDescriptionLabel]
    )
    private lazy var itemNameAndPriceStack = UIStackView(
        arrangedSubviews: [foodNameLabel, foodPriceLabel]
    )

    private let imageView = UIImageView()
    private let foodNameLabel = UILabel()
    private let foodPriceLabel = UILabel()
    private let foodDescriptionLabel = UILabel()
    private let addToOrderButton = UIButton(configuration: .filled())

    override func viewDidLoad() {
        super.viewDidLoad()

        configureViews(withMenuItem: menuItem)
        layoutSubviews()
    }

    func configureViews(withMenuItem menuItem: MenuItem) {
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

        foodInfoStack.axis = .vertical
        foodInfoStack.distribution = .fill
        foodInfoStack.spacing = 8

        itemNameAndPriceStack.axis = .horizontal
        itemNameAndPriceStack.distribution = .fill

        foodNameLabel.text = menuItem.name
        foodNameLabel.textColor = .black
        foodNameLabel.font = .systemFont(ofSize: 14)
        foodNameLabel.setContentHuggingPriority(UILayoutPriority(250), for: .horizontal)

        foodPriceLabel.text = menuItem.price.formatted(.currency(code: Locale.current.currencyCode ?? "usd"))
        foodPriceLabel.textColor = .black
        foodPriceLabel.font = .systemFont(ofSize: 14)

        foodDescriptionLabel.text = menuItem.details
        foodDescriptionLabel.textColor = .gray
        foodDescriptionLabel.font = .systemFont(ofSize: 12)
        foodDescriptionLabel.numberOfLines = 0

        addToOrderButton.setTitle("Add To Order", for: .normal)
        addToOrderButton.addTarget(self, action: #selector(addToOrderButtonTapped), for: .touchUpInside)

        imageView.image = UIImage(systemName: "photo.on.rectangle")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true

        Task {
            if let image = try? await menuController.fetchImage(fromURL: menuItem.imageUrl) {
                imageView.image = image
            }
        }
    }

    func layoutSubviews() {
        view.addSubview(foodInfoStack)
        view.addSubview(addToOrderButton)

        foodInfoStack.translatesAutoresizingMaskIntoConstraints = false
        itemNameAndPriceStack.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        addToOrderButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            foodInfoStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            foodInfoStack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            foodInfoStack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),

            itemNameAndPriceStack.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            itemNameAndPriceStack.trailingAnchor.constraint(equalTo: imageView.trailingAnchor),

            imageView.heightAnchor.constraint(equalToConstant: 200),

            addToOrderButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addToOrderButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addToOrderButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            addToOrderButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }

    @objc func addToOrderButtonTapped() {
        addMenuItemToOrder()
        animateButtonTap(addToOrderButton)
    }

    func addMenuItemToOrder() {
        menuController.order.menuItems.append(menuItem)
    }

    func animateButtonTap(_ sender: UIButton) {
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 0.1,
            options: [],
            animations: {
                self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.5, y: 2.0)
                self.addToOrderButton.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            },
            completion: nil
        )
    }

}
