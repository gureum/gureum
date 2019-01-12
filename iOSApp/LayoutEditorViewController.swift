//
//  LayoutEditorViewController.swift
//  iOS
//
//  Created by Jeong YunWon on 7/31/14.
//  Copyright (c) 2014 youknowone.org. All rights reserved.
//

import UIKit

var selectedLayoutInAddLayoutView: String?

class LayoutEditorViewController: PreviewViewController, UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    @IBOutlet var tableView: UITableView!
    @IBOutlet var editBarButtonItem: UIBarButtonItem!
    @IBOutlet var doneBarButtonItem: UIBarButtonItem!

    @IBAction func editButtonTouched(sender _: UIBarButtonItem!) {
        tableView.isEditing = !tableView.isEditing
        if tableView.isEditing {
            navigationItem.rightBarButtonItem = doneBarButtonItem
            tableView.insertSections(NSIndexSet(index: 1) as IndexSet, with: .bottom)
        } else {
            navigationItem.rightBarButtonItem = editBarButtonItem
            tableView.deleteSections(NSIndexSet(index: 1) as IndexSet, with: .top)
        }
    }

    func numberOfSectionsInTableView(tableView _: UITableView) -> Int {
        // if self.navigationItem.rightBarButtonItem == self.doneBarButtonItem {
        return 2
        // } else {
        //    return 1
        // }
    }

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            let number = preferences.layouts.count
            return number
        } else {
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 {
            var cell = tableView.dequeueReusableCell(withIdentifier: "add") as UITableViewCell?
            return cell!
        }

        let cell = (tableView.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell?)!

        let layoutNames = preferences.layouts
        let row = indexPath.row
        let title = layoutNames[row]
        // println("names: \(layoutNames) / row: \(row) / title: \(title)")
        cell.textLabel?.text = title

        let defaultLayoutIndex = preferences.defaultLayoutIndex
        if indexPath.row == defaultLayoutIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath as IndexPath, animated: true)
        if indexPath.section == 0 {
            preferences.defaultLayoutIndex = indexPath.row
            tableView.reloadData()
            inputPreviewController.reloadInputMethodView()
        }
    }

    func tableView(_: UITableView, canFocusRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 0
    }

    public func tableView(_: UITableView, canEditRowAt _: IndexPath) -> Bool {
        return true
    }

    func tableView(_: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 0 {
            return .delete
        } else {
            return .insert
        }
    }

    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            assert(indexPath.section == 0)
            var layouts = preferences.layouts
            layouts.remove(at: indexPath.row)
            preferences.layouts = layouts
            let indexPaths: Array<Any> = [indexPath]
            tableView.deleteRows(at: indexPaths as! [IndexPath], with: .top)
        case .insert:
            assert(indexPath.section == 1)
            performSegue(withIdentifier: "add", sender: self)
        case .none:
            assert(false)
        }

        inputPreviewController.reloadInputMethodView()
    }

    public func tableView(_: UITableView, targetIndexPathForMoveFromRowAt _: IndexPath, toProposedIndexPath proposedDestinationIndexPath: IndexPath) -> IndexPath {
        if proposedDestinationIndexPath.section > 0 {
            let layoutCount = preferences.layouts.count
            return IndexPath(row: layoutCount - 1, section: 0)
        } else {
            return proposedDestinationIndexPath
        }
    }

    public func tableView(_: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        var layouts = preferences.layouts
        let removed = layouts.remove(at: sourceIndexPath.row)
        layouts.insert(removed, at: destinationIndexPath.row) // - (sourceIndexPath.row > destinationIndexPath.row ? 1 : 0))
        preferences.layouts = layouts

        inputPreviewController.reloadInputMethodView()
    }
}

class AddLayoutTableViewController: UITableViewController {
    public override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) {
            selectedLayoutInAddLayoutView = cell.detailTextLabel!.text
            navigationController!.popViewController(animated: true)
        } else {
            assert(false)
        }
    }
}
