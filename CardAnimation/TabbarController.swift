//
//  TabbarController.swift
//  CardAnimation
//
//  Created by Kai Nguyen on 2/16/23.
//

import Foundation
import UIKit

class TabbarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        UITabBar.appearance().backgroundColor = .white
        addItems()
    }
    
    func addItems() {
        let vc = ViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.tabBarItem.title = "Home"
        viewControllers = [nav]
    }
}
