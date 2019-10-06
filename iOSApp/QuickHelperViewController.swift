//
//  QuickHelperViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 12. 26..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

let QuickHelperResult: NSMutableDictionary = NSMutableDictionary()
var QuickHelperJoined = false

class QuickHelperTableViewController: UITableViewController {
    var doneButtonTitle: String? { return NSLocalizedString("Next", comment: "Next button of wizard") }

    lazy var doneButton: UIBarButtonItem = {
        let button: UIBarButtonItem
        if let title = self.doneButtonTitle {
            button = UIBarButtonItem(title: NSLocalizedString("Next", comment: "Next button of wizard"), style: .plain, target: self, action: #selector(QuickHelperTableViewController.done(_:)))
        } else {
            button = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(QuickHelperTableViewController.done(_:)))
        }
        button.isEnabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = doneButton
    }

    func helperKey() -> String {
        assert(false)
        return ""
    }

    func nextSegueIdentifier() -> String {
        assert(false)
        return ""
    }

    @objc func done(_ sender: UIBarButtonItem) {
        performSegue(withIdentifier: nextSegueIdentifier(), sender: sender)
    }
}

@objc class SelectableQuickHelperTableViewController: QuickHelperTableViewController {
    var selectedIndexPaths: [IndexPath] = []
    var needsSelection: Bool = true

    override func viewWillDisappear(_: Bool) {
        let key = helperKey()
        QuickHelperResult[key] = selectedIndexPaths
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedIndexPaths.contains(indexPath) {
            selectedIndexPaths = selectedIndexPaths.filter { indexPath != $0 }
        } else {
            selectedIndexPaths.append(indexPath)
        }
        doneButton.isEnabled = !needsSelection || selectedIndexPaths.count > 0
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.accessoryType = selectedIndexPaths.contains(indexPath) ? .checkmark : .none
        return cell
    }
}

class SingleSelectableQuickHelperTableViewController: SelectableQuickHelperTableViewController {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndexPaths = [indexPath]
        doneButton.isEnabled = selectedIndexPaths.count > 0
        tableView.reloadData()
    }
}

class MainLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
        QuickHelperJoined = true
    }

    override func helperKey() -> String {
        return "main"
    }

    override func nextSegueIdentifier() -> String {
        if let indexPath: IndexPath = self.selectedIndexPaths.last {
            return indexPath.row < 2 ? "hangeul" : "10key"
        } else {
            assert(false)
            return ""
        }
    }
}

class RomanLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView(tableView, didSelectRowAt: IndexPath(row: 0, section: 0))
    }

    override func helperKey() -> String {
        return "left"
    }

    override func nextSegueIdentifier() -> String {
        return "right"
    }
}

class TenKeyLeftLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {
    override func helperKey() -> String {
        return "left"
    }

    override func nextSegueIdentifier() -> String {
        return "right"
    }
}

class RightLayoutQuickHelperTableViewController: SelectableQuickHelperTableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        selectedIndexPaths = [IndexPath(row: 0, section: 0)]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        needsSelection = false
        doneButton.isEnabled = true
    }

    override func helperKey() -> String {
        return "right"
    }

    override func nextSegueIdentifier() -> String {
        return "settings"
    }
}

class SettingsQuickHelperTableViewController: SelectableQuickHelperTableViewController {
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        selectedIndexPaths = [IndexPath(row: 0, section: 0), IndexPath(row: 1, section: 0)]
        doneButton.isEnabled = true
    }

    override func helperKey() -> String {
        return "settings"
    }

    override func nextSegueIdentifier() -> String {
        return "done"
    }
}
