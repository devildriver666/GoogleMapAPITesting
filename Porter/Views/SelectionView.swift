//
//  SelectionView.swift
//  //  GoogleMapAPI
//
//  Created by abhijeet upadhyay on 22/01/18.
//  Copyright © 2018 self. All rights reserved.
//

import UIKit

class SelectionView: UIView {

    @IBOutlet weak var toGreenView: UIView!
    @IBOutlet weak var fromRedView: UIView!
    @IBOutlet weak var toLabel: UILabel!
    @IBOutlet weak var fromLabel: UILabel!
    @IBOutlet weak var toButton: UIButton!
    @IBOutlet weak var fromButton: UIButton!
    @IBOutlet weak var blockLabel: UILabel!
    @IBOutlet weak var topView: UIView!
    @IBOutlet weak var toTopCnstraint: NSLayoutConstraint!
    
    
    @IBOutlet weak var topViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var blockLabelHeightConstraint:NSLayoutConstraint!
    
}
