//
//  AppDelegate.swift
//  printful_internal
//
//  Created by Eugene Mokhan on 04/04/2023.
//

import UIKit
import Services

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var services: ServicesContextProtocol!
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        services = ServicesContext()

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        let viewController = createMapController()
        window?.rootViewController = viewController

        return true
    }
}

// MARK: - Private methods

private extension AppDelegate {
    func createMapController() -> UIViewController {
        let handlers = MapResources.Handlers()
        let mapFactory = MapFactory()
        let viewController = mapFactory.createController(handlers: handlers, services: services)
        return viewController
    }
}
