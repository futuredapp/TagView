//
//  TagViewDelegate.swift
//  TagView
//
//  Created by Martin Pinka on 24.02.16.
//  Copyright © 2016 Martin Pinka. All rights reserved.
//

import Foundation

protocol TagViewDelegate {
    
    func selectTagAtIndex(index : Int)
    func deselectTagAtIndex(index : Int)
    
}
