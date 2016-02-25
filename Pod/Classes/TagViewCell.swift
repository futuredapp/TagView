//
//  TagViewCell.swift
//  TagView
//
//  Created by Martin Pinka on 24.02.16.
//  Copyright © 2016 Martin Pinka. All rights reserved.
//

import UIKit

public class TagViewCell: UIView {


    var tagLabel: UILabel!
    var customConstraints: [NSLayoutConstraint] = []
    var index : Int = -1
    var height : NSLayoutConstraint!

    override var frame : CGRect {
        didSet {
            self.layer.cornerRadius = CGRectGetHeight(frame) / 2
            self.layer.masksToBounds = true   
        }
    }
    
    var notSelectedFont : UIFont = UIFont.systemFontOfSize(17) {
        willSet(font) {
            
            if (!selected) {
                self.tagLabel!.font = font

            }
            
        }
        
    }
    
    var notSelectedFontColor : UIColor = UIColor.blueColor() {
        willSet(color) {
            if (!selected) {
                self.tagLabel!.textColor = color

            }
        }
    }
    
    
    var notSelectedColor : UIColor = UIColor.greenColor() {
        willSet(color) {
            if (!selected) {
                self.backgroundColor = color
            }
        }
    }
    
    var notSelectedBorderColor : UIColor? {
        didSet(color) {
            setBorders(selected)
        }
    }
    
    var selectedFont : UIFont = UIFont.systemFontOfSize(17) {
        willSet(font) {
            if (selected) {
                self.tagLabel!.font = font
                self.sizeToFit()
            }
        }
        
    }
    
    var selectedFontColor : UIColor = UIColor.grayColor() {
        willSet(color) {
            if (selected) {
                self.tagLabel!.textColor = color
            }
        }
    }
    var selectedColor : UIColor = UIColor.darkGrayColor() {
        willSet(color) {
            if (selected) {
                self.backgroundColor = color
            }
        }
    }
    
    var selectedBorderColor : UIColor? {
        willSet(color) {
            setBorders(selected)
        }
    }
    
        // MARK: - Life cycle
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.commonInit()
            
        }
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            self.commonInit()
        }
        
        
        func commonInit() {
            
            // Setup label
            self.tagLabel = UILabel()
            self.addSubview(self.tagLabel)
            self.setupConstraintsForLabel()
            self.tagLabel.textAlignment = .Center
            
            self.layer.cornerRadius = CGRectGetHeight(self.layer.frame) / 2
            self.layer.masksToBounds = true
        }
        
        func setupConstraintsForLabel() {
            self.tagLabel.translatesAutoresizingMaskIntoConstraints = false
            
            let views = ["label": self.tagLabel]
            
            let horizontalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[label]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)
            //let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat("V:|-[label(22)]-|", options: NSLayoutFormatOptions(), metrics: nil, views: views)

            let centerY = NSLayoutConstraint(item: self.tagLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: -1)
            height = NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1.0, constant: 38)
            //let center = NSLayoutConstraint(item: self.tagLabel, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0)
           // let top = NSLayoutConstraint(item: self.tagLabel, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 30)
            //let bottom = NSLayoutConstraint(item: self.tagLabel, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 30)
            
            
            self.addConstraints(horizontalConstraints)
            //self.addConstraints(verticalConstraints)
            self.addConstraints([centerY,height])
            
        }
        
        
        var selected : Bool = false {
            willSet(selected) {
                if (selected) {
                    self.tagLabel!.font = selectedFont
                    self.tagLabel!.textColor = selectedFontColor
                    self.backgroundColor = selectedColor
                } else {
                    self.tagLabel!.font = notSelectedFont
                    self.tagLabel!.textColor = notSelectedFontColor
                    self.backgroundColor = notSelectedColor
                }
                setBorders(selected)

            }
        }
        
        private func setBorders(selected : Bool ) {
            
            
            if (selected) {
                
                if let color = selectedBorderColor?.CGColor {
                    addBordersWithColor(color)
                } else {
                    removeBorders()
                }
            } else {
                
                
                if let color = notSelectedBorderColor?.CGColor {
                    addBordersWithColor(color)
                } else {
                    removeBorders()
                }
                
            }
            
        }
        
        private func addBordersWithColor(color : CGColor) {
            self.layer.borderWidth = 1.0
            self.layer.borderColor = color
        }
        
        private func removeBorders() {
            self.layer.borderWidth = 0.0
        }
        
        
        func setText(text:String) {
            tagLabel.text = text
         //   tagLabel.layoutIfNeeded()
        }
    
    


}
