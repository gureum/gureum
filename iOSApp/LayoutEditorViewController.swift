//
//  LayoutEditorViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import UIKit

var selectedLayoutInAddLayoutView: String? = nil

class LayoutEditorViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet var preview: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!

    let inputMethodViewController: InputMethodViewController! = InputMethodViewController(nibName: "InputMethod", bundle: nil)

    override func viewDidLoad()  {
        super.viewDidLoad()
        assert(self.preview)
        assert(self.inputMethodViewController)
        assert(self.inputMethodViewController.view)
        self.preview.addSubview(self.inputMethodViewController.view)
        self.inputMethodViewController.loadFromPreferences()
    }

    @IBAction func editButtonTouched(sender: UIBarButtonItem!) {
        self.tableView.editing = !self.tableView.editing
        if self.tableView.editing {
            self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
            self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Bottom)
        } else {
            self.navigationItem.rightBarButtonItem = self.editBarButtonItem
            self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Top)
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        //if self.navigationItem.rightBarButtonItem == self.doneBarButtonItem {
            return 2
        //} else {
        //    return 1
        //}
    }

    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let number = preferences.layouts.count;
            return number
        } else {
            return 1
        }
    }

    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell!  {
        if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("add") as UITableViewCell!
            return cell
        }

        var cell = tableView.dequeueReusableCellWithIdentifier("cell") as UITableViewCell!

        let layoutNames = preferences.layouts
        let row = indexPath.row
        let title = layoutNames[row]
        cell.textLabel.text = title

        let defaultLayoutIndex = preferences.defaultLayoutIndex
        if indexPath.row == defaultLayoutIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }

    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)  {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            preferences.defaultLayoutIndex = indexPath.row
            tableView.reloadData()
            self.inputMethodViewController.loadFromPreferences()
        }
    }

    func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        return indexPath.section == 0
    }

    func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool  {
        return true
    }

    func tableView(tableView: UITableView!, editingStyleForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .Delete
        } else {
            return .Insert
        }
    }

    func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        switch editingStyle {
        case .Delete:
            assert(indexPath.section == 0)
            var layouts = preferences.layouts
            layouts.removeAtIndex(indexPath.row)
            preferences.layouts = layouts
            tableView.deleteRowsAtIndexPaths([indexPath] as [AnyObject], withRowAnimation: .Top)
        case .Insert:
            assert(indexPath.section == 1)
            self.performSegueWithIdentifier("add", sender: self)
        case .None:
            assert(false)
        }

        self.inputMethodViewController.loadFromPreferences()
    }

    func tableView(tableView: UITableView!, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath!, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath!) -> NSIndexPath! {
        if proposedDestinationIndexPath.section > 0 {
            let layoutCount = preferences.layouts.count
            return NSIndexPath(forRow: layoutCount - 1, inSection: 0)
        } else {
            return proposedDestinationIndexPath
        }
    }

    func tableView(tableView: UITableView!, moveRowAtIndexPath sourceIndexPath: NSIndexPath!, toIndexPath destinationIndexPath: NSIndexPath!) {
        var layouts = preferences.layouts
        let removed = layouts.removeAtIndex(sourceIndexPath.row)
        layouts.insert(removed, atIndex: destinationIndexPath.row)// - (sourceIndexPath.row > destinationIndexPath.row ? 1 : 0))
        preferences.layouts = layouts

        self.inputMethodViewController.loadFromPreferences()
    }

}


class AddLayoutTableViewController: UITableViewController {
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        selectedLayoutInAddLayoutView = cell.detailTextLabel.text
        self.navigationController.popViewControllerAnimated(true)
    }
}
