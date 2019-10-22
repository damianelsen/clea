//
//  SelfSizedTableView.swift
//  Clea
//
//  Created by Damian Elsen on 10/18/19.
//  Copyright © 2019 Damian Elsen. All rights reserved.
//

import UIKit

class SelfSizedTableView: UITableView {
    
    override func reloadData() {
        super.reloadData()
        self.invalidateIntrinsicContentSize()
        self.layoutIfNeeded()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        invalidateIntrinsicContentSize()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: contentSize.width, height: contentSize.height)
    }
    
}
