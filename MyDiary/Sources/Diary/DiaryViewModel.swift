//
//  DiaryViewModel.swift
//  MyDiary
//
//  Created by Jinwoo Kim on 28/03/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import UIKit

protocol DiaryViewModelDelegate: class {
    func didRemoveDiary()
    func didAddDiary()
}

class DiaryViewModel {
    
    // MARK:- Properties
    private let environment: Environment
    
    private var repository: DiaryRepository {
        return self.environment.diaryRepository
    }
    
    private var diary: Diary?   // 현재 상태의 일기
    
    weak var delegate: DiaryViewModelDelegate?
    
    var hasDiary: Bool {
        return self.diary != nil
    }
    
    // internal getter, private setter
    private(set) var isEditing: Bool = false
    
    var diaryTitle: String {
        let date = self.diary?.createdAt ?? self.environment.now()
        return DateFormatter
            .formatter(with: self.environment.settings.dateFormatOption.rawValue)
            .string(from: date)
    }
    
    var diaryTextViewText: String? {
        return self.diary?.text
    }
    
    var diaryTextViewFont: UIFont {
        let fontSize: CGFloat = self.environment.settings.fontSizeOption.rawValue
        return UIFont(name: "HoonMakdR", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)
    }
    
    var saveEditButtonImage: UIImage {
        return self.isEditing
            ? R.image.save_black().safeUnwrapped
            : R.image.edit_black().safeUnwrapped
    }
    
    var removeButtonEnabled: Bool {
        return self.hasDiary
    }
    
    var diaryTextViewEditable: Bool {
        return self.isEditing
    }
    
    // MARK:- Initializing
    
    init(environment: Environment, diary: Diary? = nil) {
        self.environment = environment
        self.diary = diary
    }
    
    // MARK:- Methods
    func startEditing() {
        self.isEditing = true  // Editing 시작한다.
    }
    
    func completeEditing(with text: String) {
        self.isEditing = false
        
        // 수장하는 일기라면
        if let completedDiary = self.diary {
            completedDiary.text = text
            self.repository.update(completedDiary)
        } else {  // 새로 추가하는 일기라면
            let newDiary = Diary(text: text)
            self.repository.add(newDiary)
            self.diary = newDiary
            self.delegate?.didAddDiary()
        }
    }
    
    func removeDiary() -> Diary? {
        guard let diaryToRemove = self.diary else { return nil }
        self.repository.remove(diaryToRemove)
        self.diary = nil
        self.delegate?.didRemoveDiary() // 섹션 헤더 날짜도 없앤다.
        return diaryToRemove
    }
}
