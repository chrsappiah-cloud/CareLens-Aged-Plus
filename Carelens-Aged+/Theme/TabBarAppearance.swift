import UIKit
import SwiftUI

enum TabBarAppearance {
    static func apply() {
        applyTabBar()
        applyNavigationBar()
        applyFormAndList()
        applyButtons()
    }

    private static func applyTabBar() {
        let tabBar = UITabBarAppearance()
        tabBar.configureWithOpaqueBackground()
        tabBar.backgroundEffect = nil
        tabBar.backgroundColor = UIColor(red: 0.02, green: 0.02, blue: 0.05, alpha: 0.98)
        tabBar.shadowColor = UIColor(CareLensTheme.Colors.goldPrimary.opacity(0.5))
        tabBar.shadowImage = UIImage()

        let selected = UIColor(red: 1.0, green: 0.93, blue: 0.48, alpha: 1.0)
        let normal = UIColor(red: 0.68, green: 0.66, blue: 0.76, alpha: 1.0)

        let layouts: [UITabBarItemAppearance] = [
            tabBar.stackedLayoutAppearance,
            tabBar.inlineLayoutAppearance,
            tabBar.compactInlineLayoutAppearance
        ]

        for layout in layouts {
            layout.selected.iconColor = selected
            layout.selected.titleTextAttributes = [
                .foregroundColor: selected,
                .font: UIFont.systemFont(ofSize: 12, weight: .bold)
            ]
            layout.normal.iconColor = normal
            layout.normal.titleTextAttributes = [
                .foregroundColor: normal,
                .font: UIFont.systemFont(ofSize: 11, weight: .semibold)
            ]
        }

        UITabBar.appearance().standardAppearance = tabBar
        UITabBar.appearance().scrollEdgeAppearance = tabBar
        UITabBar.appearance().tintColor = selected
        UITabBar.appearance().unselectedItemTintColor = normal
    }

    private static func applyNavigationBar() {
        let nav = UINavigationBarAppearance()
        nav.configureWithOpaqueBackground()
        nav.backgroundColor = UIColor(red: 0.03, green: 0.02, blue: 0.08, alpha: 0.94)
        nav.shadowColor = UIColor(CareLensTheme.Colors.goldPrimary.opacity(0.25))

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .bold)
        ]
        let largeAttrs: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]

        nav.titleTextAttributes = titleAttrs
        nav.largeTitleTextAttributes = largeAttrs

        UINavigationBar.appearance().standardAppearance = nav
        UINavigationBar.appearance().scrollEdgeAppearance = nav
        UINavigationBar.appearance().compactAppearance = nav
        UINavigationBar.appearance().tintColor = UIColor(CareLensTheme.Colors.goldLight)
    }

    private static func applyFormAndList() {
        UITableView.appearance().backgroundColor = .clear
        UITableViewCell.appearance().backgroundColor = UIColor(
            red: 0.09, green: 0.07, blue: 0.15, alpha: 1.0
        )

        let label = UILabel.appearance(whenContainedInInstancesOf: [UITableViewCell.self])
        label.textColor = UIColor.white

        UISwitch.appearance().onTintColor = UIColor(CareLensTheme.Colors.emeraldGreen)
    }

    private static func applyButtons() {
        UIBarButtonItem.appearance().tintColor = UIColor(CareLensTheme.Colors.goldLight)
    }
}
