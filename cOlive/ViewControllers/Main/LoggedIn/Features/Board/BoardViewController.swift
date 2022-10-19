//
//  BoardViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 23/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController, UIGestureRecognizerDelegate {

    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var placeholderView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var flatNameLabel: UILabel!

    weak var user: User?
    weak var flat: Flat?

    private var posts = Posts()

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setUpCardView()
        fetchPosts()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.tintColor = .white
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.tintColor = UIColor(named: Constants.Colors.tintColorName)

        if isMovingFromParent {
            posts.detachListeners()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.boardToEditPostSegue:
            let editPostViewController = segue.destination as! EditPostViewController
            editPostViewController.user = user
            editPostViewController.flat = flat
        case Constants.Storyboard.boardToPostSegue:
            let postViewController = segue.destination as! PostViewController
            postViewController.user = user
            postViewController.flat = flat
            postViewController.post = (sender as! PostTableViewCell).post
            postViewController.author = (sender as! PostTableViewCell).author
        default:
            break
        }
    }

    // MARK: Handlers

    @IBAction func backButtonTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}

// MARK: UITableViewDelegate, UITableViewDataSource

extension BoardViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.posts.postsArray.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.postTableViewCell) as! PostTableViewCell
        cell.post = self.posts.postsArray[indexPath.row]
        cell.author = self.flat?.members?.membersArray.first(where: { $0.userId == cell.post?.authorId } )
        cell.setupContent()

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? PostTableViewCell else { return }
        cell.isSelected = false
        self.performSegue(withIdentifier: Constants.Storyboard.boardToPostSegue, sender: cell)
    }
}

// MARK: Private

private extension BoardViewController {
    func setupView() {
        flatNameLabel.text = flat?.name
    }

    func fetchPosts() {
        if let flat = flat {
            posts.fetch(flat: flat) { [weak self] in
                if self?.posts.postsArray.count ?? 0 > 0 {
                    self?.postsTableView.reloadData()
                    self?.activityIndicator.stopAnimating()
                    self?.postsTableView.isHidden = false
                    self?.placeholderView.isHidden = true
                } else {
                    self?.activityIndicator.stopAnimating()
                    self?.placeholderView.isHidden = false
                    self?.postsTableView.isHidden = true
                }
            }
        }
    }

    func setUpCardView() {
        let y = 0
        let w = Int(view.frame.width)
        let h = Int(cardView.bounds.height)
        let outerCornerRadius = 24
        let innerCornerRadius = 28
        let cgOuterCornerRadius = CGFloat(outerCornerRadius)
        let cgInnerCornerRadius = CGFloat(innerCornerRadius)

        let clippingPath = UIBezierPath()
        clippingPath.move(to: CGPoint(x: 0, y: y))
        clippingPath.addLine(to: CGPoint(x: 0, y: y + outerCornerRadius))
        clippingPath.addArc(withCenter: CGPoint(x: outerCornerRadius, y: y + outerCornerRadius), radius: cgOuterCornerRadius, startAngle: .pi, endAngle: 1.5 * .pi, clockwise: true)
        clippingPath.addLine(to: CGPoint(x: w / 2 - innerCornerRadius, y: y))
        clippingPath.addArc(withCenter: CGPoint(x: w / 2, y: y), radius: cgInnerCornerRadius, startAngle: 0, endAngle: .pi, clockwise: true)
        clippingPath.addLine(to: CGPoint(x: w - outerCornerRadius, y: y))
        clippingPath.addArc(withCenter: CGPoint(x: w - outerCornerRadius, y: y + outerCornerRadius), radius: cgOuterCornerRadius, startAngle: 1.5 * .pi, endAngle: 0, clockwise: true)
        clippingPath.addLine(to: CGPoint(x: w, y: h))
        clippingPath.addLine(to: CGPoint(x: 0, y: h))
        clippingPath.addLine(to: CGPoint(x: 0, y: outerCornerRadius))
        clippingPath.close()

        let mask = CAShapeLayer()
        mask.path = clippingPath.cgPath
        mask.fillRule = .evenOdd
        mask.fillColor = UIColor.blue.cgColor
        cardView.layer.mask = mask
    }
}
