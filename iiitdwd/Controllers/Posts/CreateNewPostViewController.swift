//
//  CreateNewPostViewController.swift
//  iiitdwd
//
//  Created by Souvik Das on 21/10/21.
//

import UIKit

class CreateNewPostViewController: UITabBarController {
    
    private let headerView = CreatePostHeaderView()
        
    // Title field
    private let titleField: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Enter Title"
        field.textAlignment = .center
        field.autocapitalizationType = .none
        field.autocorrectionType = .yes
        field.keyboardType = .default
        field.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 10
//        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    private let tags: UITextField = {
        let field = UITextField()
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        field.leftViewMode = .always
        field.placeholder = "Enter Tags/Labels ex: Mental Health, Club, Science"
        field.font = .italicSystemFont(ofSize: 15)
        field.autocapitalizationType = .none
        field.autocorrectionType = .yes
        field.keyboardType = .default
        field.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        field.layer.masksToBounds = true
        field.layer.cornerRadius = 10
//        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    // Image Header
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "text.below.photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 32, weight: .ultraLight))
        imageView.tintColor = .systemPink
//        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // TextView for post
    private let textView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        textView.dataDetectorTypes = .all
        textView.autocorrectionType = .yes
        textView.font = .systemFont(ofSize: 15)
        textView.sizeToFit()
//        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.isUserInteractionEnabled = true
        textView.isScrollEnabled = true
        
        return textView
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.isHidden = true
        indicator.style = .large
        indicator.backgroundColor = .separator
        indicator.layer.cornerRadius = 30
        return indicator
    }()
    
    private var selectedHeaderImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        
        
        view.addSubview(headerView)
        
        view.addSubview(titleField)
        view.addSubview(tags)
        view.addSubview(headerImageView)
        view.addSubview(textView)
        
        let tap = UITapGestureRecognizer(target: self,
                                         action: #selector(didTapHeader))
        headerImageView.addGestureRecognizer(tap)
        configureButtons()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        headerView.frame = CGRect(x: 0, y: 0, width: view.width, height: view.height)
        

        titleField.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width - 20, height: 50)
        

        tags.frame = CGRect(x: 10, y: titleField.bottom + 5, width: view.width - 20, height: 50)
        

        headerImageView.frame = CGRect(x: 10, y: tags.bottom+5, width: view.width - 20, height: 160)
        

        textView.frame = CGRect(x: 10, y: headerImageView.bottom, width: view.width - 20, height: view.height-headerImageView.bottom+10)
//        textView.frame = CGRect(x: 10, y: headerImageView.bottom, width: view.width - 20, height: view.height)
        
        activityIndicator.frame = CGRect(x: view.width/2 - 30, y: view.height/2 - 30, width: 60, height: 60)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWilHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    @objc private func didTapHeader() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true)
    }
    
    private func configureButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Post",
            style: .done,
            target: self,
            action: #selector(didTapPost)
        )
        
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
    }
    
    private func configureDismissButtons() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .done,
            target: self,
            action: #selector(didTapDismiss)
        )
        
        navigationItem.rightBarButtonItem?.tintColor = .systemPink
    }
    
    @objc private func didTapDismiss(){
        view.endEditing(true)
    }
    @objc private func didTapPost() {
        
        // Check data and post
        guard let title = titleField.text,
              let tags = tags.text,
              let body = textView.text,
              let headerImage = selectedHeaderImage,
              let email = UserDefaults.standard.string(forKey: "email"),
              !title.trimmingCharacters(in: .whitespaces).isEmpty,
              !body.trimmingCharacters(in: .whitespaces).isEmpty else {
                  
                  let alert = UIAlertController(title: "Enter Post Details",
                                                message: "Please enter a title, body, and select a image to continue.",
                                                preferredStyle: .alert)
                  alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                  present(alert, animated: true)
                  return
              }
        
        print("Starting post...")
        
        view.isUserInteractionEnabled = false
        navigationItem.rightBarButtonItem = nil
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        let newPostId = UUID().uuidString
        
        // Upload header Image
        StorageManager.shared.uploadBlogHeaderImage(
            email: email,
            image: headerImage,
            postId: newPostId
        ) { success in
            guard success else {
                self.configureButtons()
                self.view.isUserInteractionEnabled = true
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                return
            }
            StorageManager.shared.downloadUrlForPostHeader(email: email, postId: newPostId) { url in
                guard let headerUrl = url else {
                    DispatchQueue.main.async {
                        self.configureButtons()
                        self.view.isUserInteractionEnabled = true
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        HapticsManager.shared.vibrate(for: .error)
                    }
                    return
                }
                
                // Insert of post into DB
                DatabaseManager.shared.getUser(email: UserDefaults.standard.value(forKey: "email") as! String){ user in
                    guard let thisUser = user else {
                        self.configureButtons()
                        self.view.isUserInteractionEnabled = true
                        self.activityIndicator.isHidden = true
                        self.activityIndicator.stopAnimating()
                        return
                    }
                    let date = Date()
                    let format = DateFormatter()
                    format.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let timestamp = format.string(from: date)
                    let post = BlogPost(
                        identifier: newPostId,
                        title: title,
                        tags: tags,
                        timestamp: timestamp,
                        headerImageUrl: headerUrl,
                        text: body,
                        author: thisUser.name
                    )
                    
                    DatabaseManager.shared.insert(blogPost: post, email: email) { [weak self] posted in
                        guard posted else {
                            DispatchQueue.main.async {
                                self?.configureButtons()
                                self?.view.isUserInteractionEnabled = true
                                self?.activityIndicator.isHidden = true
                                self?.activityIndicator.stopAnimating()
                                HapticsManager.shared.vibrate(for: .error)
                            }
                            return
                        }
                        
                        DispatchQueue.main.async {
                            self?.configureButtons()
                            self?.view.isUserInteractionEnabled = true
                            self?.activityIndicator.isHidden = true
                            self?.activityIndicator.stopAnimating()
                            HapticsManager.shared.vibrate(for: .success)
                            self?.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
        
    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            configureDismissButtons()
            
            if textView.isFirstResponder {
                textView.backgroundColor = .systemGray
                textView.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width - 20, height: view.height - keyboardHeight - view.safeAreaInsets.top)
//                textView.frame = CGRect(x: 10, y: view.safeAreaInsets.top, width: view.width - 20, height: view.height - keyboardHeight - headerImageView.bottom)
                
            }
        }
    }
    
    @objc private func keyboardWilHide(_ notification: Notification) {
        
        configureButtons()
        
        if textView.isFirstResponder {
            textView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            textView.frame = CGRect(x: 10, y: headerImageView.bottom+10, width: view.width - 20, height: view.height-headerImageView.bottom - view.safeAreaInsets.bottom)
            
//            textView.frame = CGRect(x: 10, y: headerImageView.bottom+10, width: view.width - 20, height: view.height)
        }
        
    }
}

extension CreateNewPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {
            return
        }
        selectedHeaderImage = image
        headerImageView.image = image
    }
}
