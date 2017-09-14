//
//  TMNavigationThemeProtocol.swift
//  consumer
//
//  Created by Gregory Sapienza on 4/10/17.
//  Copyright © 2017 Human Ventures Co. All rights reserved.
//

import UIKit

protocol TMNavigationThemeProtocol {
    var navigationThemeHandler: ((NavigationTheme) -> Void)? { get set }
}

extension TMNavigationThemeProtocol where Self:  UIViewController {
    func updateNavigationBar(navigationTheme: NavigationTheme) {
        navigationThemeHandler?(navigationTheme)
    }
}
