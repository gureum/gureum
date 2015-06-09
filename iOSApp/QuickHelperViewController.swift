//
//  QuickHelperViewController.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 12. 26..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

let QuickHelperResult: NSMutableDictionary = NSMutableDictionary()

class QuickHelperTableViewController: UITableViewController {
    var doneButtonTitle: String? {
        get { return NSLocalizedString("Next", comment: "Next button of wizard") }
    }
    lazy var doneButton: UIBarButtonItem = {
        let button: UIBarButtonItem
        if let title = self.doneButtonTitle {
            button = UIBarButtonItem(title: NSLocalizedString("Next", comment: "Next button of wizard"), style: .Bordered, target: self, action: "done:")
        } else {
            button = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "done:")
        }
        button.enabled = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.rightBarButtonItem = self.doneButton
    }

    func helperKey() -> String {
        assert(false)
        return ""
    }

    func nextSegueIdentifier() -> String {
        assert(false)
        return ""
    }

    func done(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier(self.nextSegueIdentifier(), sender: sender)
    }
}

class SelectableQuickHelperTableViewController: QuickHelperTableViewController {
    var selectedIndexPaths: [NSIndexPath] = []
    var needsSelection: Bool = true

    override func viewWillDisappear(animated: Bool) {
        let key = self.helperKey()
        QuickHelperResult[key] = self.selectedIndexPaths
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if contains(self.selectedIndexPaths, indexPath) {
            self.selectedIndexPaths = self.selectedIndexPaths.filter({ !indexPath.isEqual($0) })
        } else {
            self.selectedIndexPaths.append(indexPath)
        }
        self.doneButton.enabled = !self.needsSelection || self.selectedIndexPaths.count > 0
        tableView.reloadData()
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        cell.accessoryType = contains(self.selectedIndexPaths, indexPath) ? .Checkmark : .None
        return cell
    }
}

class SingleSelectableQuickHelperTableViewController: SelectableQuickHelperTableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.selectedIndexPaths = [indexPath]
        self.doneButton.enabled = self.selectedIndexPaths.count > 0
        tableView.reloadData()
    }
}

class MainLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
    }

    override func helperKey() -> String {
        return "main"
    }

    override func nextSegueIdentifier() -> String {
        if let indexPath: NSIndexPath = self.selectedIndexPaths.last {
            return indexPath.row < 2 ? "hangeul" : "10key"
        } else {
            assert(false)
            return ""
        }
    }
}

class RomanLayoutQuickHelperTableViewController: SingleSelectableQuickHelperTableViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView(self.tableView, didSelectRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))
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

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.needsSelection = false
        self.doneButton.enabled = true
    }

    override func helperKey() -> String {
        return "right"
    }

    override func nextSegueIdentifier() -> String {
        return "settings"
    }
}

class SettingsQuickHelperTableViewController: SelectableQuickHelperTableViewController {

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.selectedIndexPaths = [NSIndexPath(forRow: 0, inSection: 0), NSIndexPath(forRow: 1, inSection: 0)]
        self.doneButton.enabled = true
    }

    override func helperKey() -> String {
        return "settings"
    }

    override func nextSegueIdentifier() -> String {
        return "done"
    }
}
