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

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        fetchComments()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupView()

        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        navigationController?.navigationBar.prefersLargeTitles = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier {
        case Constants.Storyboard.postToEditPostSegue:
            let editPostViewController = segue.destination as! EditPostViewController
            editPostViewController.user = user
            editPostViewController.flat = flat
            editPostViewController.post = post
        default:
            break
        }
    }

    // MARK: Handlers

    @IBAction func sendButtonTapped(_ sender: Any) {
        handleSendComment(userId: user?.documentId, content: commentTextField.text)
    }
}

// MARK: UITableViewDelegate, UITableViewDataSource

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

// MARK: Private

private extension PostViewController {
    func fetchComments() {
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

    func setupView() {
        authorImageView.user = author?.user
        authorImageView.setContent()
        userImageView.user = user
        authorDisplayNameLabel.text = author?.user?.displayName ?? ""
        postTitleLabel.text = post?.title ?? ""
        postContentLabel.text = post?.content ?? ""

        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Constants.Locales.defaultLocale
        postDateLabel.text = formatter.string(for: post?.date ?? Date())

        if let image = post?.image {
            postImageImageView.isHidden = false
            postImageImageView.image = image
            postImageImageViewHeightConstraint.constant = image.size.height * postImageImageView.bounds.width / image.size.width
        } else {
            postImageImageView.isHidden = true
        }

        if post?.authorId != user?.documentId {
            editBarButtonItem.isEnabled = false
            editBarButtonItem.image = UIImage()
        }
    }

    func handleSendComment(userId: String?, content: String?) {
        guard let userId else { return }

        if content?.count ?? 0 > 0 {
            let comment = Comment(authorId: userId, date: Date(), content: content!)
            comment.save(flat: flat, postId: post?.documentId) {
                self.commentTextField.text = ""
            }
        }
    }
}
