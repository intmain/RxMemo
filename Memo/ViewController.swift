//
//  ViewController.swift
//  Memo
//
//  Created by Leonard on 2016. 10. 17..
//  Copyright © 2016년 Leonard. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ViewController: UIViewController {
    
    let datasource = ["memo1", "memo2", "memo3","memo4", "memo5", "memo6","memo7", "memo8", "memo9"]
    let disposeBag = DisposeBag()
    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bindDataSource()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }


}


// MARK: - Rx
extension ViewController {
    func bindDataSource() {
        Observable.of(datasource).bindTo(collectionView.rx.items(cellIdentifier: "MemoCell", cellType: MemoCell.self)) {  index, item, cell in
            cell.memoLabel.text = "\(index+1): item"
        }.addDisposableTo(disposeBag)
    }
}
