//
//  GRKeyboardLayoutHelper.swift
//  Gureum
//
//  Created by Jeong YunWon on 2014. 6. 3..
//  Copyright (c) 2014년 youknowone.org. All rights reserved.
//

import UIKit

protocol GRKeyboardLayoutHelperDelegate {
    func insetsForHelper(helper: GRKeyboardLayoutHelper) -> UIEdgeInsets
    func numberOfRowsForHelper(helper: GRKeyboardLayoutHelper) -> Int
    func helper(helper: GRKeyboardLayoutHelper, numberOfColumnsInRow: Int) -> Int
    func helper(helper: GRKeyboardLayoutHelper, heightOfRow: Int) -> CGFloat
    func helper(helper: GRKeyboardLayoutHelper, columnWidthInRow: Int) -> CGFloat
    func helper(helper: GRKeyboardLayoutHelper, leftButtonsForRow: Int) -> Array<UIButton>
    func helper(helper: GRKeyboardLayoutHelper, rightButtonsForRow: Int) -> Array<UIButton>

    func helper(helper: GRKeyboardLayoutHelper, generatedButtonForPosition: GRKeyboardLayoutHelper.Position) -> UIButton;
}

class GRKeyboardLayoutHelper {
    struct Position: Hashable {
        let row: Int;
        let column: Int;
        var hashValue: Int {
        get {
            return Int(row << 16 + column);
        }
        }

        init(tuple: (Int, Int)) {
            (self.row, self.column) = tuple
        }

        init(row: Int, column: Int) {
            (self.row, self.column) = (row, column)
        }
    }


    var delegate: GRKeyboardLayoutHelperDelegate?
    var buttons: Dictionary<Position, UIButton> = [:];

    init(delegate: GRKeyboardLayoutHelperDelegate?) {
        self.delegate = delegate;
    }

    func buttonAt(position: Position) -> UIButton? {
        if !self.delegate {
            return nil
        }

        return self.buttons[position]
    }

    func layoutIn(view: UIView) {
        for (_, button) in self.buttons {
            button.removeFromSuperview()
        }
        self.buttons.removeAll()

        if let delegate = self.delegate {
            var rowHeightSum: CGFloat = 0.0
            var columnWidthSums = Array<CGFloat>()

            let insets = delegate.insetsForHelper(self)
            let insetFrame = UIEdgeInsetsInsetRect(view.frame, insets)
            let rowCount = delegate.numberOfRowsForHelper(self)
            for row in 0..<rowCount {
                let rowHeight = delegate.helper(self, heightOfRow: row)
                let columnWidth: CGFloat = delegate.helper(self, columnWidthInRow: row)
                let columnCount = delegate.helper(self, numberOfColumnsInRow: row)
                let leftButtons = delegate.helper(self, leftButtonsForRow: row)
                let rightButtons = delegate.helper(self, rightButtonsForRow: row)

                for column in 0..<columnCount {
                    let position = Position(tuple: (row, column))
                    var button = delegate.helper(self, generatedButtonForPosition: position)
                    button.frame = CGRectMake(0, 0, columnWidth, rowHeight)
                    self.buttons[position] = button
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
                columnWidthSums += columnWidthSum
            }

            let rowSpace = rowCount > 1 ? (insetFrame.size.height - rowHeightSum) / CGFloat(rowCount - 1) : 0.0

            for row in 0..<rowCount {
                let rowHeight = delegate.helper(self, heightOfRow: row)
                let columnWidth = delegate.helper(self, columnWidthInRow: row)
                let columnCount = delegate.helper(self, numberOfColumnsInRow: row)
                let leftButtons = delegate.helper(self, leftButtonsForRow: row)
                let rightButtons = delegate.helper(self, rightButtonsForRow: row)

                let columnSpace = (insetFrame.size.width - columnWidthSums[row]) / CGFloat(columnCount + leftButtons.count + rightButtons.count - 1)
                let rowTop = insets.top + (rowHeight + rowSpace) * CGFloat(row)
                var left = insets.left
                for button in leftButtons {
                    let width = button.frame.size.width
                    button.removeFromSuperview()
                    view.addSubview(button)
                    button.frame = CGRectMake(left, rowTop, width, rowHeight)
                    button.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
                    left += width + columnSpace
                }
                for column in 0..<columnCount {
                    let position = Position(tuple: (row, column))
                    var button = self.buttons[position]!
                    button.frame.origin = CGPointMake(left, rowTop)
                    button.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
                    view.addSubview(button)
                    left += columnWidth + columnSpace
                }
                for button in rightButtons {
                    let width = button.frame.size.width
                    button.removeFromSuperview()
                    view.addSubview(button)
                    button.frame = CGRectMake(left, rowTop, width, rowHeight)
                    button.autoresizingMask = .FlexibleLeftMargin | .FlexibleRightMargin | .FlexibleTopMargin | .FlexibleBottomMargin
                    left += width + columnSpace
                }
            }
        }
    }
}

func ==(lhs: GRKeyboardLayoutHelper.Position, rhs: GRKeyboardLayoutHelper.Position) -> Bool {
    return lhs.row == rhs.row && lhs.column == rhs.column
}
