//
//  MemoManager.swift
//  Memo
//
//  Created by Leonard on 2016. 10. 21..
//  Copyright © 2016년 Leonard. All rights reserved.
//

import Foundation
import RxSwift
import RxDataSources
import RxCocoa

class MemoManager: NSObject {
    static let instance: MemoManager =  {
        return MemoManager()
    }()
    
    var datasource: Variable<[SectionModel<Int,String>]> = {
        return Variable([SectionModel(model:1, items: ["a", "b", "c"])])
    }()
    
    func addMemo(_ memo: String) {
        guard var newItems = self.datasource.value.first?.items else { return }
        newItems.append(memo)
        let newSectionModel = SectionModel(model: 1, items: newItems)
        self.datasource.value = [newSectionModel]
    }
}

extension Reactive where Base: MemoManager {
    var memo: UIBindingObserver<MemoManager, String> {
        return UIBindingObserver(UIElement: self.base, binding: { (memoManager, memo) in
            memoManager.addMemo(memo)
        })
    }
}
