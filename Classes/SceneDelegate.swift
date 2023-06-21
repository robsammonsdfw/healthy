//
//  SceneDelegate.swift
//  DietMasterGoPlus
//
//  Created by Henry T Kirk on 6/21/23.
//

import UIKit

/// SceneDelegate is the modern (iOS 13+) replacement for AppDelegate (in a way).
/// It is the foundation for multi-window support and other features.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        windowScene.delegate = self

        let rootViewController = UINavigationController(rootViewController: DietMasterGoViewController())
        let menuFAB = MainMenuFAB()
        menuFAB.presentInNavController(controller: rootViewController)
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene // <-- Window Scene set to UIWindow
        window?.rootViewController = rootViewController
        window?.overrideUserInterfaceStyle = .light
        UIWindow.appearance().overrideUserInterfaceStyle = .light
        window?.makeKeyAndVisible()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.applicationDidBecomeActive?(UIApplication.shared)
    }
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.applicationWillResignActive?(UIApplication.shared)
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.applicationWillEnterForeground?(UIApplication.shared)
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.applicationDidEnterBackground?(UIApplication.shared)
    }

    func windowScene(_ windowScene: UIWindowScene, didUpdate previousCoordinateSpace: UICoordinateSpace, interfaceOrientation previousInterfaceOrientation: UIInterfaceOrientation, traitCollection previousTraitCollection: UITraitCollection) {
        // Something changed in the scene! Resize!!
    }

    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        let appDelegate = UIApplication.shared.delegate
        _ = appDelegate?.application?(UIApplication.shared, continue: userActivity, restorationHandler: { (object) in
            // No-op.
        })
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let context = URLContexts.first else {
            return
        }

        let appDelegate = UIApplication.shared.delegate
        _ = appDelegate?.application?(UIApplication.shared, open: context.url, options: [:])
    }

}
