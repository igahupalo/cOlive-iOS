//
//  PostViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 23/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class PostViewController: UIViewController {

    @IBOutlet weak var authorImageView: ProfileImageView!
    @IBOutlet weak var authorDisplayNameLabel: UILabel!
    @IBOutlet weak var postImageImageView: UIImageView!
    @IBOutlet weak var postDateLabel: UILabel!
    @IBOutlet weak var postTitleLabel: UILabel!
    @IBOutlet weak var postContentLabel: UILabel!
    @IBOutlet weak var postImageImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var userImageView: ProfileImageView!
    @IBOutlet weak var commentTextField: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var commentsTableViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var commentsTableView: UITableView!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    
    weak var user: User?
    weak var post: Post?
    weak var author: Member?
    weak var flat: Flat?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupComments()

        guard let flat = flat else {
            return
        }

        self.post?.fetchComments(flat: flat) {
            self.commentsTableView.reloadData()
            let commentNumber = self.commentsTableView.numberOfRows(inSection: 0)
            self.commentsLabel.text = "\(commentNumber) comment\(commentNumber == 1 ? "" : "s")"
            self.commentsTableViewHeightConstraint.constant = CGFloat(self.commentsTableView.numberOfRows(inSection: 0) * 64)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setupContent()

        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.postToEditPostSegue:
            let editPostViewController = segue.destination as! EditPostViewController
            editPostViewController.user = self.user
            editPostViewController.flat = self.flat
            editPostViewController.post = self.post
        default:
            break
        }
    }

    func setupContent() {
        self.authorImageView.user = user
        self.authorImageView.setContent()
        self.authorDisplayNameLabel.text = self.user?.displayName ?? "Author"
        let formatter = RelativeDateTimeFormatter()
        self.postDateLabel.text = formatter.string(for: self.post?.date ?? Date())
        if let image = self.post?.image {
            self.postImageImageView.isHidden = false
            self.postImageImageView.image = image
            self.postImageImageViewHeightConstraint.constant = image.size.height * self.postImageImageView.bounds.width / image.size.width
        } else {
            self.postImageImageView.isHidden = true
        }
        self.postTitleLabel.text = self.post?.title ?? "Title"
        self.postContentLabel.text = self.post?.content ?? "Content"

        if self.post?.authorId != self.user?.documentId {
            editBarButtonItem.isEnabled = false
            editBarButtonItem.image = UIImage()
        }
    }

    func setupComments() {
        self.userImageView.user = self.user
    }

    @IBAction func sendButtonTapped(_ sender: Any) {
        guard let userId = self.user?.documentId else {
            return
        }

        let content = commentTextField.text
        if (content?.count ?? 0) > 0 {
            let comment = Comment(authorId: userId, date: Date(), content: content!)
            comment.save(flat: self.flat, postId: self.post?.documentId) {
                self.commentTextField.text = ""
                
            }
        }
    }
}


extension PostViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.post?.comments?.commentsArray.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CellIdentifiers.commentTableViewCell) as! CommentTableViewCell
        cell.comment = self.post?.comments?.commentsArray[indexPath.row]
        cell.author = self.flat?.members?.membersArray.first(where: { $0.userId == cell.comment?.authorId } )
        cell.setupContent()

        return cell
    }
}
