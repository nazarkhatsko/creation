//
//  CVCMain.swift
//  Creation
//
//  Created by Nazar Khatsko on 1/28/20.
//  Copyright © 2020 Nazar Khatsko. All rights reserved.
//

import UIKit

class CVCMain: UICollectionViewCell {
    @IBOutlet weak var imagePicture: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var buttonSegue: UIButton!
    
    @IBOutlet weak var buttonRemove: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
