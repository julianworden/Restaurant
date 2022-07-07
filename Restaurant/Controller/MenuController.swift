//
//  DataController.swift
//  Restaurant
//
//  Created by Julian Worden on 7/4/22.
//

import Foundation
import UIKit

class MenuController {
    enum MenuControllerError: Error, LocalizedError {
        case categoriesNotFound
        case categoriesDecodeError
        case menuItemsNotFound
        case menuItemsDecodeError
        case imageNotFound
        case imageDecodeFailed
        case orderRequestFailed
        case orderDecodeError
    }

    static let shared = MenuController()
    static let orderUpdatedNotification = Notification.Name("MenuController.orderUpdated")

    var order = Order() {
        didSet {
            NotificationCenter.default.post(name: MenuController.orderUpdatedNotification, object: nil)
        }
    }
    let baseURL = URL(string: "http://localhost:8080/")!

    func fetchCategories() async throws -> [String] {
        let categoriesURL = baseURL.appendingPathComponent("categories")
        let (data, response) = try await URLSession.shared.data(from: categoriesURL)

        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            print(response)
            throw MenuControllerError.categoriesNotFound
        }

        guard let categoriesResponse = try? JSONDecoder().decode(CategoriesResponse.self, from: data) else {
            throw MenuControllerError.categoriesDecodeError
        }

        return categoriesResponse.categories
    }

    func fetchMenuItems(forCategory category: String) async throws -> [MenuItem] {
        let baseMenuURL = baseURL.appendingPathComponent("menu")
        var urlComponents = URLComponents(url: baseMenuURL, resolvingAgainstBaseURL: true)!
        urlComponents.queryItems = [URLQueryItem(name: "category", value: category)]
        let menuURL = urlComponents.url!

        let (data, response) = try await URLSession.shared.data(from: menuURL)

        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            print(response)
            throw MenuControllerError.menuItemsNotFound
        }

        print(data.prettyPrintedJSONString())

        guard let menuResponse = try? JSONDecoder().decode(MenuResponse.self, from: data) else {
            throw MenuControllerError.menuItemsDecodeError
        }

        return menuResponse.items
    }

    func fetchImage(fromURL url: URL) async throws -> UIImage {
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            print(response)
            throw MenuControllerError.imageNotFound
        }

        guard let image = UIImage(data: data) else {
            throw MenuControllerError.imageDecodeFailed
        }

        return image
    }

    typealias MinutesToPrepare = Int
    func submitOrder(forMenuIDs menuIDs: [Int]) async throws -> MinutesToPrepare {
        let orderURL = baseURL.appendingPathComponent("order")

        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let menuIDsDictionary = ["menuIds": menuIDs]
        let jsonEncoder = JSONEncoder()
        let jsonData = try? jsonEncoder.encode(menuIDsDictionary)
        request.httpBody = jsonData

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let response = response as? HTTPURLResponse,
              response.statusCode == 200 else {
            print(response)
            throw MenuControllerError.orderRequestFailed
        }

        guard let orderResponse = try? JSONDecoder().decode(OrderResponse.self, from: data) else {
            throw MenuControllerError.orderDecodeError
        }

        return orderResponse.prepTime
    }
}
