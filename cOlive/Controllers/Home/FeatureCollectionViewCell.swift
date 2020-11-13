//
//  FeatureCollectionViewCell.swift
//  cOlive
//
//  Created by Iga Hupalo on 11/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class FeatureCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        DispatchQueue.main.async {
            self.alpha = 1.0
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 0.5
            })

        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1.0
            })
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        DispatchQueue.main.async {
            self.alpha = 0.5
            UIView.animate(withDuration: 0.2, animations: {
                self.alpha = 1.0
            })
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor(named: "Mint")?.cgColor ?? UIColor.cyan.cgColor, UIColor(named: "MintLight")?.cgColor ?? UIColor.cyan.cgColor]
        gradientLayer.cornerRadius = self.cornerRadius
        self.layer.insertSublayer(gradientLayer, at: 0)
    }


}
