//
//  AppDelegate.swift
//  EloGeoApp
//
//  Created by Евгений Доленко on 29/04/2019.
//  Copyright © 2019 Евгений Доленко. All rights reserved.
//

import UIKit
import Swinject
import IQKeyboardManagerSwift
import GoogleMaps
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let container = MainDIContainer.get()

    static var model = AppModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        initRealm()
        initGoogleMaps()

        if (AppDelegate.model.auth.isAuthorized) {
            Router.showMain()
        } else {
            Router.showAuth()
        }

        if #available(iOS 13.0, *) {
            window?.overrideUserInterfaceStyle = .light
        }

        LocationService.sharedInstance.startIfNeeded()
        return true
    }

    private func initGoogleMaps() {
        GMSServices.provideAPIKey("AIzaSyDCwZPakiG8mbfHaOA6RYTfM_4tf680f-w")
    }

    private func initRealm() {
        let config = Realm.Configuration(
                schemaVersion: 1,
                deleteRealmIfMigrationNeeded: true
        )

        Realm.Configuration.defaultConfiguration = config
    }
}

