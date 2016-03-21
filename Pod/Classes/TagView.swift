//
//  TagView.swift
//  TagView
//
//  Created by Martin Pinka on 24.02.16.
//  Copyright © 2016 Martin Pinka. All rights reserved.
//

import UIKit

public class TagView: UIView, UIScrollViewDelegate {
    
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
    
    var contentView = UIScrollView()
    var contentViewToBottomConstraint: NSLayoutConstraint!
    
    public var enabledScrolling : Bool = true {
        didSet {
            contentView.enabledScrolling = enabledScrolling
        }
    }
        
    /// UIPageControl is added to superview on-demand in `showPageControl:` method
    private(set) public var pageControl = UIPageControl()
    private let kPageControlHeight: CGFloat = 15.0
    
    /// Set a value for max allowed height of contentView or nil for unlimited height
    public var maxAllowedHeight: Float? {
        willSet {
            if newValue <= 0 {
                fatalError("Value for 'maxAllowedHeight' must be greater than zero.")
            }
        }
    }
    
    /// Set a value for max allowed number of rows of contentView or nil for unlimited rows
    public var maxAllowedRows: UInt?
    
    /// current number of pages
    private(set) var numberOfPages = 1
    
    // MARK: - UIView life cycle
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        reloadData()
        invalidateIntrinsicContentSize()
    }
    
    func configure() {
        tapRecognizer =  UITapGestureRecognizer(target: self, action: "tapSelect:")
        selectionEnabled = false
        
        contentView.pagingEnabled = true
        contentView.showsHorizontalScrollIndicator = false
        contentView.delegate = self
        
        addSubview(contentView)
        
        contentView.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["contentView": contentView]
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[contentView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|[contentView]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings)
        self.addConstraints(verticalConstraints)
        self.contentViewToBottomConstraint = verticalConstraints.last!
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
    
    
    // MARK: - Layout
    
    public func reloadData() {
        
        contentHeight = 0
        var y : CGFloat = 0
        var line = 0
        
        for subview in tagViews {
            subview.removeFromSuperview()
        }
        
        tagViews = []
        
        guard let dataSource = dataSource else {
            invalidateIntrinsicContentSize()
            return
        }
        
        let selfWidth = intrinsicContentSize().width
        
        var currentPageIndex: Int = 0
        var pages: [[[TagViewCell]]] = [[]] // [page][row][item]
        
        var rowsWidth : [[CGFloat]] = [[]] // [page][row] = width
        var currentLine : [TagViewCell] = []
        
        
        var currentLineWidth : CGFloat = 0
        let numberOfTags = dataSource.numberOfTags(self)
        
        if numberOfTags == 0 {
            invalidateIntrinsicContentSize()
            return
        }
        
        func isNewPageRequired() -> Bool {
            let newRowCount = pages[currentPageIndex].count + 1
            let newPageHeight = (dataSource.heightOfTag(self) + self.cellInsets.top + cellInsets.bottom) * (CGFloat(newRowCount) )
            
            if let maxAllowedRows = self.maxAllowedRows where newRowCount > Int(maxAllowedRows) {

                return true
            } else if let maxAllowedHeight = self.maxAllowedHeight where Float(newPageHeight) > maxAllowedHeight {
                return true
            } else {
                return false
            }
        }
        
        func addNewPage() {
            currentPageIndex++
            pages.append([])
            rowsWidth.append([])
            y = 0
        }
        
        for i in 0..<numberOfTags {

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
                
                // put the line on the next page if needed
                if isNewPageRequired() {
                    addNewPage()
                }
                
                pages[currentPageIndex].append(currentLine)
                rowsWidth[currentPageIndex].append(currentLineWidth)
                
                
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
            if isNewPageRequired() {
                addNewPage()
            }
            
            // we're done, finish off by adding the last row
            pages[currentPageIndex].append(currentLine)
            rowsWidth[currentPageIndex].append(currentLineWidth)
        }
        
        // Add all pages of rows of cell views to this view
        // and update contentHeight
        for pageIndex in 0..<pages.count {
            
            let currentPageHeight = (dataSource.heightOfTag(self) + self.cellInsets.top + cellInsets.bottom) * CGFloat(pages[pageIndex].count)
            contentHeight = max(contentHeight, currentPageHeight)
            
            for lineIndex in  0..<pages[pageIndex].count {
                self.addLine(lineIndex, ofTagViewCells: pages[pageIndex][lineIndex], currentLineWidth: rowsWidth[pageIndex][lineIndex], toPage: pageIndex)
            }
        }
        
        
        numberOfPages = pages.count
        if numberOfPages > 1 {
            showPageControl(withPageCount: numberOfPages)
        } else {
            hidePageControl()
        }
        
        
        self.contentView.contentSize = CGSizeMake(self.bounds.width * CGFloat(numberOfPages), contentHeight)
        
        self.invalidateIntrinsicContentSize()
        
    }
    
    func addLine(line : Int, ofTagViewCells cells : [TagViewCell], currentLineWidth : CGFloat, toPage pageIndex: Int) {
        
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
        
        offset += (CGFloat(pageIndex) * self.bounds.width)
        var lastFrame = CGRectMake(offset, y, 0, 0)
        
        for addCell in cells {
            addCell.frame = CGRectOffset(addCell.frame, lastFrame.size.width + lastFrame.origin.x + cellInsets.left, y)
            contentView.addSubview(addCell)
            
            lastFrame = CGRectOffset(addCell.frame,  cellInsets.right, 0)
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    var previousPage = 0
    
    public func scrollViewDidScroll(scrollView: UIScrollView) {
        
        if !(numberOfPages > 1) { return }
        
        let pageWidth = scrollView.bounds.size.width
        let fractionalPage = Double(scrollView.contentOffset.x / pageWidth)
        let currentPage = lround(fractionalPage)
        
        if (previousPage != currentPage) {
            previousPage = currentPage
            pageControl.currentPage = currentPage
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func changePage(sender: UIPageControl) {
        contentView.setContentOffset(CGPointMake(self.bounds.size.width * CGFloat(sender.currentPage), 0), animated: true)
    }
    
    // MARK: - Autolayout
    
    override public func invalidateIntrinsicContentSize() {
        super.invalidateIntrinsicContentSize()
        
    }
    
    override public func intrinsicContentSize() -> CGSize {
        var height: CGFloat = contentHeight
        
        // Add extra space for page control
        if /*let pcHeight = pageControl.frame.height where*/ pageControl.hidden == false {
            height += pageControl.frame.height //pcHeight
        }
        
        let size = CGSizeMake(frame.width, height)
        return size
    }
    
    
    // MARK: - Helpers
    
    private func showPageControl(withPageCount pageCount: Int) {
        if pageControl.superview == nil {
            pageControl.addTarget(self, action: Selector("changePage:"), forControlEvents: UIControlEvents.ValueChanged)
            self.addSubview(pageControl)
            
            // Autolayout
            pageControl.translatesAutoresizingMaskIntoConstraints = false
            let bindings = ["pageControl": pageControl]
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[pageControl]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
            self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pageControl(\(kPageControlHeight))]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
        }
        
        contentViewToBottomConstraint.constant = kPageControlHeight
        pageControl.numberOfPages = pageCount
        pageControl.hidden = false
    }
    
    private func hidePageControl() {
        contentViewToBottomConstraint.constant = 0
        pageControl.hidden = true
    }
    
    private func findBottomMost() -> CGRect {
        
        var bottomMost = CGRectZero
        
        for cell in tagViews {
            if CGRectGetMaxY(cell.frame) > CGRectGetMaxY(bottomMost) {
                bottomMost = cell.frame
            }
        }
        
        return bottomMost
    }
    
    
}
