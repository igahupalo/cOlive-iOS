//
//  EditPostViewController.swift
//  cOlive
//
//  Created by Iga Hupalo on 23/11/2020.
//  Copyright © 2020 Iga Hupalo. All rights reserved.
//

import UIKit

class EditPostViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet var imageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postImageView: UIView!
    @IBOutlet weak var postImageImageView: UIImageView!
    @IBOutlet weak var deleteImageButton: UIButton!
    @IBOutlet weak var selectImageButton: UIButton!
    @IBOutlet weak var postTitleTextField: MaterialTextField!
    @IBOutlet weak var postContentTextView: MaterialTextView!
    @IBOutlet weak var barButtonItem: UIBarButtonItem!

    weak var user: User?
    var post: Post?
    weak var flat: Flat?

    private var imagePicker: ImagePicker!
    private var postTitleErrorMessage = ""

    private var isValidTitle: Bool {
        if let title = postTitleTextField.text {
            return title.count > 0
        }
        return false
    }

    // MARK: Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imagePicker = ImagePicker(presentationController: self, delegate: self)

        if let _ = post {
            setupEditMode()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }

    // MARK: Handlers

    @IBAction func selectImageButtonTapped(_ sender: Any) {
        imagePicker.present(from: postImageImageView)
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.5) {
            self.selectImageButton.isHidden = false
            self.postImageImageView.image = UIImage()
            self.postImageView.isHidden = true
        }
    }

    @IBAction func addButtonTapped(_ sender: Any) {
        handleAddPost()
    }
}

extension EditPostViewController: ImagePickerDelegate {
    func didSelect(image: UIImage?) {
        UIView.animate(withDuration: 0.5) {
            self.selectImageButton.isHidden = true
            self.postImageImageView.image = image
            self.postImageView.isHidden = false
        }
    }
}

private extension EditPostViewController {
    func handleAddPost() {
        if !isValidTitle {
            postTitleErrorMessage = Constants.EditPostErrorMessages.emptyPostTitle
            postTitleTextField.setError(message: postTitleErrorMessage)
            return
        }

        let title = postTitleTextField.text!
        let content = postContentTextView.text
        let image = postImageImageView.image

        if let authorId = user?.documentId {
            if let post = post {
                post.setData(title: title, content: content, date: Date(), authorId: authorId, image: image, isActive: post.isActive)
            } else {
                post = Post(title: title, content: content, authorId: authorId, image: image)
            }

            guard let flatId = flat?.documentId else {
                return
            }

            post?.save(flatId: flatId) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }
    }

    func setupEditMode() {
        // TODO: Add constants
        headerLabel.text = "Edit post"
        barButtonItem.title = "Save"
        postTitleTextField.text = post?.title
        postContentTextView.text = post?.content

        if let image = post?.image {
            selectImageButton.isHidden = true
            postImageView.isHidden = false
            postImageImageView.image = image
        }
    }
}
