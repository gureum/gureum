//
//  LayoutEditorViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import UIKit

var LayoutEditorSelectedLayoutInAddLayoutView: String? = nil

class LayoutEditorViewController: PreviewViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!

    @IBAction func editButtonTouched(sender: UIBarButtonItem!) {
        self.tableView.editing = !self.tableView.editing
        if self.tableView.editing {
            self.navigationItem.rightBarButtonItem = self.doneBarButtonItem
            //self.tableView.insertSections(NSIndexSet(index: 1), withRowAnimation: .Bottom)
        } else {
            self.navigationItem.rightBarButtonItem = self.editBarButtonItem
            //self.tableView.deleteSections(NSIndexSet(index: 1), withRowAnimation: .Top)
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let newLayout = LayoutEditorSelectedLayoutInAddLayoutView {
            var layouts = preferences.layouts
            layouts.append(newLayout)
            preferences.layouts = layouts
            LayoutEditorSelectedLayoutInAddLayoutView = nil
            self.tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: count(layouts) - 1, inSection: 0)], withRowAnimation: .Top)
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let number = preferences.layouts.count;
            return number
        } else {
            return 1
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCellWithIdentifier("add") as? UITableViewCell
            return cell!
        }

        let cell = (tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell)!

        let layoutName = preferences.layouts[indexPath.row]
        let title = NSLocalizedString(layoutName, comment: "layout title")
        //println("names: \(layoutNames) / row: \(row) / title: \(title)")
        cell.textLabel!.text = title

        let defaultLayoutIndex = preferences.defaultLayoutIndex
        if indexPath.row == defaultLayoutIndex {
            cell.accessoryType = .Checkmark
        } else {
            cell.accessoryType = .None
        }

        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)  {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.section == 0 {
            preferences.defaultLayoutIndex = indexPath.row
            tableView.reloadData()
            self.inputPreviewController.reloadInputMethodView()
        }
    }

    func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0
    }

    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool  {
        return indexPath.section > 0 || preferences.layouts.count > 1
    }

    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .Delete
        } else {
            return .Insert
        }
    }

    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        switch editingStyle {
        case .Delete:
            assert(indexPath.section == 0)
            let defaultLayoutIndex = preferences.defaultLayoutIndex
            var layouts = preferences.layouts
            let oldLayoutName = layouts[defaultLayoutIndex]

            layouts.removeAtIndex(indexPath.row)
            preferences.layouts = layouts


            if defaultLayoutIndex > indexPath.row {
                preferences.defaultLayoutIndex -= 1
            }
            else if defaultLayoutIndex == indexPath.row {
                if defaultLayoutIndex == 0 {
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row + 1, inSection: 0))!
                    cell.accessoryType = .Checkmark
                } else {
                    let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: indexPath.row - 1, inSection: 0))!
                    cell.accessoryType = .Checkmark
                    preferences.defaultLayoutIndex -= 1
                }
            }

            let newLayoutName = layouts[preferences.defaultLayoutIndex]
            assert(oldLayoutName == newLayoutName)

            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Top)
        case .Insert:
            assert(indexPath.section == 1)
            self.performSegueWithIdentifier("add", sender: self)
        case .None:
            assert(false)
        }

        self.inputPreviewController.reloadInputMethodView()
    }

    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if proposedDestinationIndexPath.section > 0 {
            let layoutCount = preferences.layouts.count
            return NSIndexPath(forRow: layoutCount - 1, inSection: 0)
        } else {
            return proposedDestinationIndexPath
        }
    }

    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        let defaultLayoutIndex = preferences.defaultLayoutIndex
        var layouts = preferences.layouts
        let oldLayoutName = layouts[defaultLayoutIndex]

        let removed = layouts.removeAtIndex(sourceIndexPath.row)
        layouts.insert(removed, atIndex: destinationIndexPath.row)// - (sourceIndexPath.row > destinationIndexPath.row ? 1 : 0))
        preferences.layouts = layouts


        if defaultLayoutIndex == sourceIndexPath.row {
            preferences.defaultLayoutIndex = destinationIndexPath.row
        }
        else if sourceIndexPath.row < defaultLayoutIndex && defaultLayoutIndex <= destinationIndexPath.row {
            preferences.defaultLayoutIndex -= 1
        }
        else if destinationIndexPath.row <= defaultLayoutIndex && defaultLayoutIndex < sourceIndexPath.row {
            preferences.defaultLayoutIndex += 1
        }

        let newLayoutName = layouts[preferences.defaultLayoutIndex]
        assert(oldLayoutName == newLayoutName)

        self.inputPreviewController.reloadInputMethodView()
    }

}


class AddLayoutTableViewController: UITableViewController {
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) {
            LayoutEditorSelectedLayoutInAddLayoutView = cell.detailTextLabel!.text
            self.navigationController!.popViewControllerAnimated(true)
        } else {
            assert(false);
        }
    }
}
