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
//        Observable.of(datasource).bindTo(collectionView.rx.items(cellIdentifier: "MemoCell", cellType: MemoCell.self)) {  index, item, cell in
//            cell.memoLabel.text = "\(index+1): item"
//        }.addDisposableTo(disposeBag)
        
        collectionView.rx.items(cellIdentifier: "MemoCell", cellType: MemoCell.self)(Observable.of(datasource))( {index, item, cell in
            cell.memoLabel.text = "\(index+1): item"
        }).addDisposableTo(disposeBag)
        
// public func bindTo<R1, R2>(_ binder: (Self) -> @escaping (R1) -> R2, curriedArgument: R1) -> R2
    }
}

/**
 public func items<S: Sequence, Cell: UICollectionViewCell, O : ObservableType>
 (cellIdentifier: String, cellType: Cell.Type = Cell.self)
 -> (_ source: O)
 -> (_ configureCell: @escaping (Int, S.Iterator.Element, Cell) -> Void)
 -> Disposable where O.E == S {
 return { source in
 return { configureCell in
 let dataSource = RxCollectionViewReactiveArrayDataSourceSequenceWrapper<S> { (cv, i, item) in
 let indexPath = IndexPath(item: i, section: 0)
 let cell = cv.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! Cell
 configureCell(i, item, cell)
 return cell
 }
 
 return self.items(dataSource: dataSource)(source)
 }
 }
 }
 **/
