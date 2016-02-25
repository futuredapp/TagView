//
//  TagView.swift
//  TagView
//
//  Created by Martin Pinka on 24.02.16.
//  Copyright © 2016 Martin Pinka. All rights reserved.
//

import UIKit

public class TagView: UIView {
    
    public enum Align {
        case Center
        case Left
        case Right
    }
    
    var tapRecognizer : UITapGestureRecognizer?
    
    public var selectionEnabled : Bool = false {
        didSet {
            
            
            
            if selectionEnabled {
                self.addGestureRecognizer(tapRecognizer!)
            } else {
                self.removeGestureRecognizer(tapRecognizer!)
            }
            
            
        }
    }
    
    public var dataSource : TagViewDataSource?
    public var delegate : TagViewDelegate?
    
    public var align : Align = .Center
    public var cellInsets : UIEdgeInsets = UIEdgeInsetsMake(5, 5, 5, 5)
    
    var contentHeight : CGFloat = 0.0
    
    var tagViews : [TagViewCell] = []
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        reloadData()
        invalidateIntrinsicContentSize()
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    func configure() {
        tapRecognizer =  UITapGestureRecognizer(target: self, action: "tapSelect:")
        selectionEnabled = false
        
        
    }
    
    public func selectTagAtIndex(index:Int) {
        tagViews[index].selected = true
    }
    
    public func deselectTagAtIndex(index:Int) {
        tagViews[index].selected = false        
    }
    
    func tapSelect (sender : UITapGestureRecognizer) {
        
        if (sender.state != .Ended) {
            return
        }
        
        let loc = sender.locationInView(self)
        if let tagView  = self.hitTest(loc, withEvent: nil) as? TagViewCell {
            tagView.selected = !tagView.selected
            if tagView.selected {
                delegate?.tagView(self, didSelectTagAtIndex: tagView.index)
            } else {
                delegate?.tagView(self, didDeselectTagAtIndex: tagView.index)
            }
        }
    }
    
    public func reloadData() {
        
        
        
        var y : CGFloat = 0
        var line = 0
        
        for subview in subviews {
            subview.removeFromSuperview()
        }
        
        tagViews = []
        
        guard let dataSource = dataSource else {
            contentHeight = 0
            invalidateIntrinsicContentSize()
            return
        }
        
        let selfWidth = intrinsicContentSize().width
        
        var rows : [[TagViewCell]] = []
        var rowsWidth : [CGFloat] = []
        var currentLine : [TagViewCell] = []
        
        
        var currentLineWidth : CGFloat = 0
        let numberOfTags = dataSource.numberOfTags(self)
        
        if numberOfTags == 0 {
            contentHeight = 0
            invalidateIntrinsicContentSize()
            return
        }
        
        for i in 0...numberOfTags - 1 {
            let cell = dataSource.tagCellForTagView(self, index: i)
            
            tagViews.append(cell)
            
            let size = cell.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
            
            cell.frame = CGRectMake(0, 0, size.width, dataSource.heightOfTag(self))
            cell.height.constant = dataSource.heightOfTag(self)
            cell.index = i
            var tagWidth = cell.frame.size.width
            tagWidth += cellInsets.left + cellInsets.right
            
            
            var fullLine = false
            if currentLineWidth + tagWidth < selfWidth {
                currentLineWidth += tagWidth
                currentLine.append(cell)
            }  else {
                fullLine = true
            }
            
            if i == numberOfTags - 1 || fullLine {
                //   self.addLine(line, cells: currentLine, currentLineWidth : currentLineWidth)
                rows.append(currentLine)
                rowsWidth.append(currentLineWidth)
                
                
                currentLine = []
                currentLineWidth = 0
                line++
            } 
            
            if fullLine {
                currentLineWidth = tagWidth
                currentLine = [cell]
                y += cellInsets.top + dataSource.heightOfTag(self)
            }
            
        }
        
        if currentLine.count > 0 {
            rows.append(currentLine)
            rowsWidth.append(currentLineWidth)
            //  self.addLine(line, cells: currentLine, currentLineWidth : currentLineWidth)
            
        } 
        
        contentHeight = (dataSource.heightOfTag(self) + self.cellInsets.top + cellInsets.bottom) * CGFloat(rows.count)
        
        for i in  0...rows.count - 1 {
            self.addLine(i, cells: rows[i], currentLineWidth : rowsWidth[i])
        }
        
        self.invalidateIntrinsicContentSize()
        
    }
    
    func addLine(line : Int, cells : [TagViewCell], currentLineWidth : CGFloat) {
        
        let selfWidth = intrinsicContentSize().width
        
        let freeSpace = selfWidth - currentLineWidth
        let line = CGFloat(line)
        let y = line * self.dataSource!.heightOfTag(self) + (line + 1.0) * self.cellInsets.top + line * self.cellInsets.bottom
        
        var offset : CGFloat = 0.0
        
        switch align {
        case .Center:
            offset = freeSpace / 2
        case .Right: 
            offset = freeSpace  
        case .Left:
            offset = 0
        }
        
        var lastFrame = CGRectMake(offset, y, 0, 0)
        
        for addCell in cells {
            addCell.frame = CGRectOffset(addCell.frame, lastFrame.size.width + lastFrame.origin.x + cellInsets.left, y)
            self.addSubview(addCell)
            
            lastFrame = CGRectOffset(addCell.frame,  cellInsets.right, 0)
        }
        
        
    }
    
    override public func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        
    }
    
    override public func intrinsicContentSize() -> CGSize {
        var height : CGFloat = 0
        
        let bottomMost = self.findBottomMost()
        height = bottomMost.origin.y + cellInsets.bottom + bottomMost.size.height 
        
        return CGSizeMake(frame.width, contentHeight)
    }
    
    
    private func findBottomMost() -> CGRect {
        
        var bottomMost = CGRectZero
        for cell in subviews {            
            if cell.frame.size.height + cell.frame.origin.y > bottomMost.size.height + bottomMost.origin.y {
                bottomMost = cell.frame
            }
        }
        
        return bottomMost
    }
    
    
}
