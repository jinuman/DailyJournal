//
//  DiaryViewController.swift
//  MyDiary
//
//  Created by Jinwoo Kim on 27/03/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

class DiaryViewController: UIViewController {
    
    // MARK: - Properties
    
    private(set) var viewModel: DiaryViewModel
    
    // MARK: UI
    private lazy var guide = self.view.safeAreaLayoutGuide
    
    private let saveEditButton = UIBarButtonItem()
    private let removeButton = UIBarButtonItem()
    
    private let diaryTextView: UITextView = {
        let textView = UITextView()
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
        textView.returnKeyType = .continue
        textView.keyboardType = .default
        return textView
    }()
    
    private var diaryTextViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Initializing
    
    required init(viewModel: DiaryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        self.configure(viewModel: viewModel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        print("Diary Controller \(#function)")
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureLayout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let nc = NotificationCenter.default
        nc.addObserver(self,
                       selector: #selector(handleKeyboardAppear(_:)),
                       name: UIResponder.keyboardWillShowNotification,
                       object: nil)
        nc.addObserver(self,
                       selector: #selector(handleKeyboardAppear(_:)),
                       name: UIResponder.keyboardWillHideNotification,
                       object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if viewModel.isEditing {
            diaryTextView.becomeFirstResponder()
        }
    }
    
    // In order to fix Notification memory leak.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Binding
    
    private func configure(viewModel: DiaryViewModel) {
        
    }
    
    // MARK: - Methods
    
    private func configureLayout() {
        self.configureNavigationBarItems()
        
        self.view.backgroundColor = .white
        
        // Add gesture to view
        let tapGesture = UITapGestureRecognizer()
        tapGesture.delegate = self
        view.addGestureRecognizer(tapGesture)
        
        // + 버튼을 통해 일기 추가면, 에디팅부터 시작하게 한다.
        if self.viewModel.hasDiary == false {
            self.viewModel.startEditing()
        }
        
        self.updateSubviews()
        
        let guide = view.safeAreaLayoutGuide
        view.addSubview(diaryTextView)
        let diaryTextviewConstraints = diaryTextView.anchor(top: guide.topAnchor,
                                                            leading: guide.leadingAnchor,
                                                            bottom: guide.bottomAnchor,
                                                            trailing: guide.trailingAnchor,
                                                            padding: UIEdgeInsets(top: 8, left: 12, bottom: 0, right: 12))
        diaryTextViewBottomConstraint = diaryTextviewConstraints.bottom
        
        self.configureAttributedDiaryTextView()
    }
    
    private func configureNavigationBarItems() {
        self.title = self.viewModel.diaryTitle
        
        self.removeButton.image = R.image.delete_black()
        self.removeButton.style = .plain
        self.removeButton.target = self
        self.removeButton.action = #selector(self.handleRemove)
        
        navigationItem.rightBarButtonItems = [
            self.removeButton,
            self.saveEditButton
        ]
    }
    
    private func configureAttributedDiaryTextView() {
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 20
        
        let attributes = [
            NSAttributedString.Key.paragraphStyle: style,
            NSAttributedString.Key.font: self.viewModel.diaryTextViewFont
        ]
        
        self.diaryTextView.attributedText = NSAttributedString(
            string: self.viewModel.diaryTextViewText ?? " ",
            attributes: attributes
        )
    }
    
    // 뷰모델에 따라 UI 업데이트
    private func updateSubviews() {
        self.saveEditButton.image = self.viewModel.saveEditButtonImage
        self.saveEditButton.target = self
        self.saveEditButton.action = self.viewModel.isEditing
            ? #selector(self.handleSave)
            : #selector(self.handleEdit)
        self.removeButton.isEnabled = self.viewModel.removeButtonEnabled
        self.diaryTextView.isEditable = self.viewModel.diaryTextViewEditable
    }
    
    @objc private func handleRemove() {
        guard self.viewModel.hasDiary else { return }
        
        let alertController = UIAlertController(title: "현재 일기를 삭제할까요?",
                                                message: "이 동작은 되돌릴 수 없습니다.",
                                                preferredStyle: .actionSheet)
        
        let removeAction = UIAlertAction(
                title: "삭제",
                style: .destructive)
        { [weak self] _ in
            guard let self = self else { return }
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc private func handleEdit() {
        viewModel.startEditing()
        updateSubviews()
        diaryTextView.becomeFirstResponder()    // 키보드 올리기
    }
    
    @objc private func handleSave() {
        guard let text = diaryTextView.text else { return }
        
        viewModel.completeEditing(with: text)
        
        let alertController = UIAlertController(title: "저장 되었습니다.",
                                                message: nil,
                                                preferredStyle: .alert)
        
        present(alertController, animated: true) { [weak self] in
            guard let self = self else { return }
            self.dismiss(animated: true, completion: nil)
        }
        
        updateSubviews()
        diaryTextView.resignFirstResponder()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc private func handleKeyboardAppear(_ notification: Notification) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as?
                NSValue),
            let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as?
                TimeInterval),
            let curve = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as?
                UInt)
            else { return }
        
        let isKeyboardWillShow: Bool = notification.name == UIResponder.keyboardWillShowNotification
        let keyboardHeight = isKeyboardWillShow
            ? keyboardFrame.cgRectValue.height
            : 0
        let animationOption = UIView.AnimationOptions.init(rawValue: curve)
        
        UIView.animate(
            withDuration:  duration,
            delay: 0.0,
            options: animationOption,
            animations: {
                self.diaryTextViewBottomConstraint?.constant = -keyboardHeight
                self.view.layoutIfNeeded()
        },
            completion: nil)
    }
}

// MARK: - Extensions

extension DiaryViewController: UIGestureRecognizerDelegate {
    // view 를 탭하면 키보드를 내린다.
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        self.view.endEditing(true)
        return true
    }
}
