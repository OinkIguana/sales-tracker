//
//  SettingsViewController.swift
//  ConArtist
//
//  Created by Cameron Eldridge on 2018-02-03.
//  Copyright © 2018 Cameron Eldridge. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SettingsViewController: UIViewController {
    enum Setting {
        case currency
        case signOut
        case feedback
        case help
    }
    
    struct Group {
        let title: String?
        let items: [Setting]
    }
    
    fileprivate let disposeBag = DisposeBag()
    
    @IBOutlet weak var settingsTableView: UITableView!
    @IBOutlet weak var navBar: FakeNavBar!

    fileprivate var settings: [Group] = [
        Group(title: "General"¡, items: [.currency]),
        Group(title: "Support"¡, items: [.signOut, .feedback, .help]),
    ]
}

// MARK: - Lifecycle
extension SettingsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar.title = "Settings"¡
        navBar.leftButtonTitle = "Back"¡
        navBar.leftButton.rx.tap
            .subscribe(onNext: { _ in ConArtist.model.navigate(back: 1) })
            .disposed(by: disposeBag)

        ConArtist.model.settings
            .asDriver()
            .drive(onNext: { [settingsTableView] _ in settingsTableView?.reloadData() })
            .disposed(by: disposeBag)
    }
}

// MARK: - UITableViewDataSource
extension SettingsViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return settings.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings[section].items.count
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settings[section].title
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = settings[indexPath.section].items[indexPath.row]
        switch item {
        case .currency:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsSelectTableViewCell.ID, for: indexPath) as! SettingsSelectTableViewCell
            cell.setup(title: "Currency"¡, value: ConArtist.model.settings.value.currency.rawValue)
            return cell
        case .signOut:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsActionTableViewCell.ID, for: indexPath) as! SettingsActionTableViewCell
            cell.setup(title: "Sign out"¡)
            return cell
        case .help:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsActionTableViewCell.ID, for: indexPath) as! SettingsActionTableViewCell
            cell.setup(title: "Help"¡)
            return cell
        case .feedback:
            let cell = tableView.dequeueReusableCell(withIdentifier: SettingsActionTableViewCell.ID, for: indexPath) as! SettingsActionTableViewCell
            cell.setup(title: "Report a bug/Request a feature"¡)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate
extension SettingsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = settings[indexPath.section].items[indexPath.row]
        switch item {
        case .signOut:
            ConArtist.model.navigate(backTo: SignInViewController.self)
            ConArtist.API.Auth.authToken = ConArtist.API.Auth.Unauthorized
            ConArtist.model.clear()
        case .help:
            break
        case .feedback:
            break
        case .currency:
            let options = CurrencyCode.variants
            SettingsSelectViewController.show(
                title: "Currency"¡,
                value: options.index(of: ConArtist.model.settings.value.currency) ?? 0,
                options: options.map { $0.rawValue },
                handler: { index in
                    ConArtist.model.settings.accept(ConArtist.model.settings.value.set(currency: options[index]))
                    _ = ConArtist.API.GraphQL.observe(mutation:
                            UpdateCurrencyMutation(currency: options[index].rawValue)
                        )
                        .subscribe()
                }
            )
        }
    }

    func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isHighlighted = true
    }

    func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        tableView.cellForRow(at: indexPath)?.isHighlighted = false
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let item = settings[indexPath.section].items[indexPath.row]
        switch item {
        case .currency,
             .signOut,
             .help,
             .feedback: return indexPath
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.tableView(tableView, titleForHeaderInSection: section).map { TableHeaderView(title: $0, showBar: false, showMore: false) }
    }
}

// MARK: - Navigation
extension SettingsViewController: ViewControllerNavigation {
    static let Storyboard: Storyboard = .Settings
    static let ID = "Settings"

    static func show() {
        let controller = instantiate()
        ConArtist.model.navigate(present: controller)
    }
}
