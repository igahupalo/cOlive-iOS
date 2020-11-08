//
//  SneakPeekView.swift
//  cOlive
//
//  Created by Iga Hupalo on 07/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit


class SlideView: UIView {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    func setContent(image: UIImage, title: String, description: String) {
        self.imageView.image = image
        self.titleLabel.text = title
        self.descriptionLabel.text = description
    }
}
