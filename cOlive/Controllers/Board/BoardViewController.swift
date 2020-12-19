//
//  BoardViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 23/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class BoardViewController: UIViewController {

    @IBOutlet weak var postsTableView: UITableView!
    @IBOutlet weak var placeholderView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    var user: User?
    var flat: Flat?

    private var posts: Posts

    required init?(coder: NSCoder) {
        self.posts = Posts()
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if let flat = flat {
            self.posts.fetch(flat: flat) {
                if self.posts.postsArray.count > 0 {
                    self.postsTableView.reloadData()
                    self.activityIndicator.stopAnimating()
                    self.postsTableView.isHidden = false
                    self.placeholderView.isHidden = true
                } else {
                    self.activityIndicator.stopAnimating()
                    self.placeholderView.isHidden = false
                    self.postsTableView.isHidden = true
                }
            }
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        if self.isMovingFromParent {
            self.posts.detachListeners()
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.boardToEditPostSegue:
            let editPostViewController = segue.destination as! EditPostViewController
            editPostViewController.user = self.user
            editPostViewController.flat = self.flat
        case Constants.Storyboard.boardToPostSegue:
            let postViewController = segue.destination as! PostViewController
            postViewController.user = self.user
            postViewController.flat = self.flat
            postViewController.post = (sender as! PostTableViewCell).post
            postViewController.author = (sender as! PostTableViewCell).author
        default:
            break
        }
    }
}

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
