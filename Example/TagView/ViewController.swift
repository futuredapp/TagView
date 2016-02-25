//
//  ViewController.swift
//  TagView
//
//  Created by Martin Pinka on 02/25/2016.
//  Copyright (c) 2016 Martin Pinka. All rights reserved.
//


import UIKit

class ViewController: UIViewController, TagViewDataSource, UITableViewDataSource {
    
    //   @IBOutlet var tagView : TagView!
    @IBOutlet var tableView : UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //        tagView.dataSource = self
        
        tableView.registerNibForCellClass(TagTableViewCell)
        
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 160.0
    }
    
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        
        //without this tagtableviewcell has wrong size. Does anyone have a solution for it?
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }
    
    func numberOfTags(tagView: TagView) -> Int {
        return 7
    }
    
    func tagCellForTagView(tagView: TagView, index: Int) -> TagViewCell {
        let cell = TagViewCell()
        let string = "tagtag tag"
        
        
        
        cell.selected = true
        cell.setText(string)
        return cell
    }
    
    func heightOfTag(tagView: TagView) -> CGFloat {
        return 100
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TagTableViewCell.reuseIdentifier) as! TagTableViewCell
        cell.tagView.dataSource = self
        cell.tagView.reloadData()
        
        let size =  cell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        print(size)
        return cell
    }
    
    
}



func classNameOf(aClass: AnyClass) -> String {
    return NSStringFromClass(aClass).componentsSeparatedByString(".").last!
}

extension UITableViewCell {
    static var nibName: String {
        return classNameOf(self)
    }
    
    static var reuseIdentifier: String {
        return classNameOf(self)
    }
}

extension UITableView {
    func registerNibForCellClass<T: UITableViewCell>(t: T.Type) {
        let nib = UINib(nibName: t.nibName, bundle: nil)
        registerNib(nib, forCellReuseIdentifier: t.reuseIdentifier)
    }
    
    func registerCellClass<T: UITableViewCell>(t: T.Type) {
        registerClass(t, forCellReuseIdentifier: t.reuseIdentifier)
    }
}

