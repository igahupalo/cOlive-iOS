//
//  StartViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 15/09/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    @IBOutlet weak var slideScrollView: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!

    var slides: [SlideView] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        setupSlideScrollView()

    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.startToLoginSegue:
            let loginViewController = segue.destination as! LogInViewController
            loginViewController.parentDelegate = self
        case Constants.Storyboard.startToSignUpSegue:
            let signUpViewController = segue.destination as! SignUpViewController
            signUpViewController.parentDelegate = self
        default:
            break
        }
    }

    func createSlides() -> [SlideView] {
        var slides: [SlideView] = []
        let images: [UIImage?] = [UIImage(named: "lamp"), UIImage(named: "coin"), UIImage(named: "stickers"), UIImage(named: "bell")]

        for i in 0...3 {
            let slide = Bundle.main.loadNibNamed("SlideView", owner: self, options: nil)?.first as! SlideView
            slide.setContent(image: images[i] ?? UIImage(), title: Constants.StartTexts.titles[i], description: Constants.StartTexts.descriptions[i])
            slides.append(slide)
        }

        return slides
    }

    func setupSlideScrollView() {
        let slides = createSlides()
        slideScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: 0)

        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: slideScrollView.frame.size.height)
            slideScrollView.addSubview(slides[i])
            print(slides[i].frame.height)
        }
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
    }
}

extension StartViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = scrollView.contentOffset.x / view.frame.width
        pageControl.currentPage = Int(pageIndex)
    }
}
