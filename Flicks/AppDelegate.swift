//
//  AppDelegate.swift
//  Flicks
//
//  Created by Xiaofei Long on 1/24/16.
//  Copyright © 2016 Xiaofei Long. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(
        application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?
    ) -> Bool {
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)

        let nowPlayingMoviesNavigationController =
            storyboard.instantiateViewControllerWithIdentifier("Movies Navigation Controller")
                as! UINavigationController
        nowPlayingMoviesNavigationController.tabBarItem.title = "Now Playing"
        nowPlayingMoviesNavigationController.tabBarItem.image = UIImage(named: "NowPlaying")

        let nowPlayingMoviesViewController =
            nowPlayingMoviesNavigationController.topViewController as! MoviesViewController
        nowPlayingMoviesViewController.endpoint = "now_playing"

        let topRatedMoviesNavigationController =
            storyboard.instantiateViewControllerWithIdentifier("Movies Navigation Controller")
                as! UINavigationController
        topRatedMoviesNavigationController.tabBarItem.title = "Top Rated"
        topRatedMoviesNavigationController.tabBarItem.image = UIImage(named: "TopRated")

        let topRatedMoviesViewController =
            topRatedMoviesNavigationController.topViewController as! MoviesViewController
        topRatedMoviesViewController.endpoint = "top_rated"

        let tabBarController = UITabBarController()
        tabBarController.tabBar.barTintColor = UIColor.blackColor()
        tabBarController.tabBar.barStyle = .Black
        tabBarController.tabBar.translucent = true
        tabBarController.viewControllers = [
            nowPlayingMoviesNavigationController,
            topRatedMoviesNavigationController
        ]

        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()

        return true
    }

}
