//
//  SceneDelegate.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

// swiftlint:disable all

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var orderTabBarItem: UITabBarItem!
    let menuController = MenuController.shared

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let tabBarController = UITabBarController()
        let menuViewController = UINavigationController(rootViewController: CategoriesViewController())
        let myOrderViewController = UINavigationController(rootViewController: OrderViewController())

        menuViewController.tabBarItem = UITabBarItem(title: "Menu", image: UIImage(systemName: "menucard"), selectedImage: nil)
        menuViewController.navigationBar.prefersLargeTitles = true
        myOrderViewController.tabBarItem = UITabBarItem(title: "My Order", image: UIImage(systemName: "cart"), selectedImage: nil)
        myOrderViewController.navigationBar.prefersLargeTitles = true

        tabBarController.setViewControllers([menuViewController, myOrderViewController], animated: false)
        tabBarController.selectedViewController = menuViewController

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        UITabBar.appearance().standardAppearance = tabBarAppearance

        let navigationBarAppearance = UINavigationBarAppearance()
        navigationBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navigationBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateOrderBadge),
            name: MenuController.orderUpdatedNotification,
            object: nil
        )

        window = UIWindow(windowScene: windowScene)
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        orderTabBarItem = (window?.rootViewController as? UITabBarController)?.viewControllers?[1].tabBarItem
    }

    @objc func updateOrderBadge() {
        switch menuController.order.menuItems.count {
        case 0:
            orderTabBarItem.badgeValue = nil
        case let count:
            orderTabBarItem.badgeValue = String(count)
        }
    }

}

