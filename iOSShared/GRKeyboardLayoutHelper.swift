//
//  GRKeyboardLayoutHelper.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 3..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

protocol GRKeyboardLayoutHelperDelegate: class {
    func layoutWillLoad(helper: GRKeyboardLayoutHelper)
    func layoutDidLoad(helper: GRKeyboardLayoutHelper)
    func layoutWillLayout(helper: GRKeyboardLayoutHelper, forRect: CGRect)
    func layoutDidLayout(helper: GRKeyboardLayoutHelper, forRect: CGRect)
    func theme(helper: GRKeyboardLayoutHelper) -> Theme

    func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets
    func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int
    func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow: Int) -> Int
    func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int, forSize: CGSize) -> CGFloat
    func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow: Int, forSize: CGSize) -> CGFloat
    func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow: Int) -> Array<UIButton>
    func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow: Int) -> Array<UIButton>

    func helper(helper: GRKeyboardLayoutHelper, buttonForPosition: GRKeyboardLayoutHelper.Position) -> GRInputButton
    func helper(helper: GRKeyboardLayoutHelper, titleForPosition: GRKeyboardLayoutHelper.Position) -> String
}

class GRKeyboardLayoutHelper {
    struct Position: Hashable {
        let row: Int
        let column: Int
        var hashValue: Int {
            return Int(row << 16 + column)
        }

        init(tuple: (Int, Int)) {
            (row, column) = tuple
        }

        init(row: Int, column: Int) {
            (self.row, self.column) = (row, column)
        }
    }

    weak var delegate: GRKeyboardLayoutHelperDelegate?
    var buttons: [Position: GRInputButton] = [:]

    init(delegate: GRKeyboardLayoutHelperDelegate?) {
        self.delegate = delegate
    }

    func buttonAt(position: Position) -> UIButton? {
        if delegate == nil {
            return nil
        }

        return buttons[position]
    }

    func createButtonsInView(view: UIView) {
        for (_, button) in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()

        if let delegate = self.delegate {
            delegate.layoutWillLoad(helper: self)

            let rowCount = delegate.numberOfRowsForHelper(helper: self)
            for row in 0 ..< rowCount {
                let columnCount = delegate.helper(helper: self, numberOfColumnsInRow: row)
                let leftButtons = delegate.helper(helper: self, leftButtonsForRow: row)
                let rightButtons = delegate.helper(helper: self, rightButtonsForRow: row)

                for button in delegate.helper(helper: self, leftButtonsForRow: row) {
                    view.insertSubview(button, belowSubview: view.subviews.last!)
                    button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                    // button.preload()
                }
                for column in 0 ..< columnCount {
                    let position = Position(tuple: (row, column))
                    var button = delegate.helper(helper: self, buttonForPosition: position)
                    buttons[position] = button
                    assert(view.subviews.count > 0)
                    view.insertSubview(button, belowSubview: view.subviews.last!)
                    button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                }
                for button in delegate.helper(helper: self, rightButtonsForRow: row) {
                    view.insertSubview(button, belowSubview: view.subviews.last as! UIView)
                    button.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
                    // button.preload()
                }
            }
            delegate.layoutDidLoad(helper: self)
        }
        updateCaptionLabel()
    }

    func layoutButtonsInRect(rect: CGRect) {
        if let delegate = self.delegate {
            delegate.layoutWillLayout(helper: self, forRect: rect)
            let theme = delegate.theme(helper: self)

            var rowHeightSum: CGFloat = 0.0
            var columnWidthSums = Array<CGFloat>()

            let insets = delegate.insetsForHelper(helper: self)
            let insetFrame = UIEdgeInsetsInsetRect(rect, insets)
            let rowCount = delegate.numberOfRowsForHelper(helper: self)
            for row in 0 ..< rowCount {
                let rowHeight = delegate.helper(helper: self, heightOfRow: row, forSize: rect.size)
                let columnWidth = delegate.helper(helper: self, columnWidthInRow: row, forSize: rect.size)
                let columnCount = delegate.helper(helper: self, numberOfColumnsInRow: row)
                let leftButtons = delegate.helper(helper: self, leftButtonsForRow: row)
                let rightButtons = delegate.helper(helper: self, rightButtonsForRow: row)

                for column in 0 ..< columnCount {
                    let position = Position(tuple: (row, column))
                    let button = buttons[position]!
                    button.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: columnWidth, height: rowHeight))
                }

                var columnWidthSum = CGFloat(columnCount) * columnWidth
                var columnLeftSum: CGFloat = 0.0
                for button in leftButtons {
                    let width = button.frame.size.width
                    columnWidthSum += width
                    columnLeftSum += width
                }
                for button in rightButtons {
                    let width = button.frame.size.width
                    columnWidthSum += width
                }

                rowHeightSum += rowHeight
                columnWidthSums.append(columnWidthSum)
            }

            let rowSpace = rowCount > 1 ? (insetFrame.size.height - rowHeightSum) / CGFloat(rowCount - 1) : 0.0
            // println("\(rowHeightSum) \(rowSpace)")
            var rowHeightSum2: CGFloat = 0.0
            for row in 0 ..< rowCount {
                let rowHeight = delegate.helper(helper: self, heightOfRow: row, forSize: rect.size)
                let columnWidth = delegate.helper(helper: self, columnWidthInRow: row, forSize: rect.size)
                let columnCount = delegate.helper(helper: self, numberOfColumnsInRow: row)
                let leftButtons = delegate.helper(helper: self, leftButtonsForRow: row)
                let rightButtons = delegate.helper(helper: self, rightButtonsForRow: row)

                let columnSpace = (insetFrame.size.width - columnWidthSums[row]) / CGFloat(columnCount + leftButtons.count + rightButtons.count - 1)
                let rowTop = insets.top + rowHeightSum2 + rowSpace * CGFloat(row)
                var left = insets.left
                for button in leftButtons {
                    let width = button.frame.size.width
                    button.frame = CGRect(x: left, y: rowTop, width: width, height: rowHeight)
                    left += width + columnSpace
                }
                for column in 0 ..< columnCount {
                    let position = Position(tuple: (row, column))
                    var button = buttons[position]!
                    button.frame.origin = CGPoint(x: left, y: rowTop)
                    left += columnWidth + columnSpace
                }
                for button in rightButtons {
                    let width = button.frame.size.width
                    button.frame = CGRect(x: left, y: rowTop, width: width, height: rowHeight)
                    left += width + columnSpace
                }
                rowHeightSum2 += rowHeight
            }
            delegate.layoutDidLayout(helper: self, forRect: rect)
        }
    }

    func updateCaptionLabel() {
        if let delegate = self.delegate {
            for (position, button) in buttons {
                if button.title(for: .normal) == nil {
                    let label = delegate.helper(helper: self, titleForPosition: position)
                    button.title = label
                }
            }
        }
    }
}

func == (lhs: GRKeyboardLayoutHelper.Position, rhs: GRKeyboardLayoutHelper.Position) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}
