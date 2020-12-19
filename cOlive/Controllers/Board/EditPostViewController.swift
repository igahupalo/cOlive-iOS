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
        if let title = self.postTitleTextField.text {
            return title.count > 0
        }
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.imagePicker = ImagePicker(presentationController: self, delegate: self)

        if let _ = post {
            self.setupEditMode()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        self.navigationController?.navigationBar.prefersLargeTitles = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        self.navigationController?.navigationBar.prefersLargeTitles = true
    }


    private func setupEditMode() {
        self.headerLabel.text = "Edit post"
        self.barButtonItem.title = "Save"
        self.postTitleTextField.text = self.post?.title
        self.postContentTextView.text = self.post?.content

        if let image = self.post?.image {
            self.selectImageButton.isHidden = true
            self.postImageView.isHidden = false
            self.postImageImageView.image = image
        }

    }

    @IBAction func selectImageButtonTapped(_ sender: Any) {
        self.imagePicker.present(from: postImageImageView)
    }

    @IBAction func deleteButtonTapped(_ sender: Any) {

        UIView.animate(withDuration: 0.5) {
            self.selectImageButton.isHidden = false
            self.postImageImageView.image = UIImage()
            self.postImageView.isHidden = true
        }
    }

    @IBAction func addButtonTapped(_ sender: Any) {

        if !isValidTitle {
            postTitleErrorMessage = Constants.EditPostErrorMessages.emptyPostTitle
            self.postTitleTextField.setError(message: postTitleErrorMessage)
            return
        }

        let title = self.postTitleTextField.text!
        let content = self.postContentTextView.text

        let image = self.postImageImageView.image

        if let authorId = user?.documentId {
            if let post = self.post {
                post.setData(title: title, content: content, date: Date(), authorId: authorId, image: image, isActive: post.isActive)
            } else {
                self.post = Post(title: title, content: content, authorId: authorId, image: image)
            }

            guard let flatId = self.flat?.documentId else {
                return
            }

            self.post?.save(flatId: flatId) { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
        }

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
