//
//  DiaryViewModelTests.swift
//  MyDiaryTests
//
//  Created by Jinwoo Kim on 2020/05/11.
//  Copyright © 2020 jinuman. All rights reserved.
//

import XCTest
import Nimble
@testable import MyDiary

class DiaryViewModelTests: XCTestCase {
    
    func testHasDiary() {
        // Setup
        let environment = Environment()
        let diary = Diary(text: "일기")
        
        // Run
        let viewModelWithDiary = DiaryViewModel(environment: environment, diary: diary)
        let viewModelWithoutDiary = DiaryViewModel(environment: environment)
        
        // Verify
        expect(viewModelWithDiary.hasDiary) == true
        expect(viewModelWithoutDiary.hasDiary) == false
    }
    
    func testTextViewText() {
        // Setup
        let environment = Environment()
        let diary = Diary(text: "일기")
        
        // Run
        let viewModel = DiaryViewModel(environment: environment, diary: diary)
        
        // Verify
        expect(viewModel.diaryTextViewText) == "일기"
    }
    
    func testTitleWhenDiaryExists() {
        // Setup
        let environment = Environment()
        let createdAt: Date = Date()
        let diary = Diary(createdAt: createdAt, text: "일기")
        
        // Run
        let viewModel = DiaryViewModel(environment: environment, diary: diary)
        
        // Verify
        expect(viewModel.diaryTitle) == DateFormatter.diaryDateFormatter.string(from: createdAt)
    }
    
    func testTitleWhenNoDiary() {
        // Setup
        let now: Date = Date()
        let environment = Environment(now: { return now })
        
        // Run
        let viewModel = DiaryViewModel(environment: environment)
        
        // Verify
        expect(viewModel.diaryTitle) == DateFormatter.diaryDateFormatter.string(from: now)
    }
    
    func testRemoveButtonEnabledWhenDiaryExists() {
        // Setup
        let environment = Environment()
        let createdAt: Date = Date()
        let diary = Diary(createdAt: createdAt, text: "일기")
        
        // Run
        let viewModel = DiaryViewModel(environment: environment, diary: diary)
        
        // Verify
        expect(viewModel.removeButtonEnabled) == true
    }
    
    func testRemoveButtonDisabledWhenNoDiary() {
        // Setup
        let environment = Environment()
        
        // Run
        let viewModel = DiaryViewModel(environment: environment)
        
        // Verify
        expect(viewModel.removeButtonEnabled) == false
    }
    
    func testUpdateOfEditingPropertiesWhenStartEditing() {
        // Setup
        let environment = Environment()
        let viewModel = DiaryViewModel(environment: environment)
        
        expect(viewModel.isEditing) == false
        expect(viewModel.diaryTextViewEditable) == false
        expect(viewModel.saveEditButtonImage) == R.image.edit_black().safeUnwrapped
        
        // Run
        viewModel.startEditing()
        
        // Verify
        expect(viewModel.isEditing) == true
        expect(viewModel.diaryTextViewEditable) == true
        expect(viewModel.saveEditButtonImage) == R.image.save_black().safeUnwrapped
    }
    
    func testUpdateOfEditingPropertiesWhenCompleteEditing() {
        // Setup
        let environment = Environment()
        let viewModel = DiaryViewModel(environment: environment)
        
        viewModel.startEditing()
        
        expect(viewModel.isEditing) == true
        expect(viewModel.diaryTextViewEditable) == true
        expect(viewModel.saveEditButtonImage) == R.image.save_black().safeUnwrapped
                
        // Run
        viewModel.completeEditing(with: "수정 끝")
        
        // Verify
        expect(viewModel.isEditing) == false
        expect(viewModel.diaryTextViewEditable) == false
        expect(viewModel.saveEditButtonImage) == R.image.edit_black().safeUnwrapped
    }
    
    func testAddDiaryToRepositoryWhenDiaryPropertyIsNil() {
        // Setup
        let repository = InMemoryDiaryRepository()
        let environment = Environment(diaryRepository: repository)
        let viewModel = DiaryViewModel(environment: environment)
        
        // Run
        viewModel.completeEditing(with: "일기 생성")
        
        // Verify
        let diary = repository.recentDiaries(max: 1).first
        expect(diary?.text) == "일기 생성"
    }
}
