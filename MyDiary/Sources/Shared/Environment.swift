//
//  Environment.swift
//  MyDiary
//
//  Created by Jinwoo Kim on 27/03/2019.
//  Copyright © 2019 jinuman. All rights reserved.
//

import Foundation

class Environment {
    let diaryRepository: DiaryRepository
    var settings: Settings
    let now: () -> Date
    
    init(
        diaryRepository: DiaryRepository = InMemoryDiaryRepository(),
        settings: Settings = InMemorySettings(),
        now: @escaping () -> Date = Date.init)
    {
        self.diaryRepository = diaryRepository
        self.settings = settings
        self.now = now
    }
}
