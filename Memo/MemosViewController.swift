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


class MemosViewController: UIViewController {

    let disposeBag = DisposeBag()
    @IBOutlet var collectionView: UICollectionView!
    override func viewDidLoad() {
        super.viewDidLoad()
        bindDataSource()
        rxAction()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

// MARK: - Rx
extension MemosViewController {
    func rxAction() {
        
        self.navigationItem.rightBarButtonItem?.rx.tap.flatMapLatest { [weak self] _ in
            return WriteMemoViewController.rx.create(self).flatMap { (writeMemoViewController: WriteMemoViewController) in
                writeMemoViewController.rx.didFinishGettingMemo
            }.take(1)
        }
        .bindTo(MemoManager.instance.rx.memo)
        .addDisposableTo(disposeBag)
        
        
        collectionView.rx.observe(CGSize.self, "contentSize")
            .filter{ size -> Bool in
                size?.height != 0
            }
            .distinctUntilChanged{ (old,new) -> Bool in
                return (old?.width == new?.width && old?.height == new?.height)
            }
            .skip(1)
            .subscribe(onNext: { [weak self] size in
                let newOffSet =  CGPoint(x: 0, y: (size?.height ?? 0) - (self?.collectionView.frame.height ?? 0))
                self?.collectionView.setContentOffset(newOffSet, animated: true)
        }).addDisposableTo(disposeBag)
    }
}

// MARK: - CollectionView
extension MemosViewController {
    
    func bindDataSource() {
        MemoManager.instance.datasource.asObservable().bindTo( collectionView.rx.items(dataSource: createDatasource())).addDisposableTo(disposeBag)
    }
    
    func createDatasource() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Int,String>> {
        let datasource = RxCollectionViewSectionedReloadDataSource<SectionModel<Int,String>>()

        
        datasource.configureCell = { datasource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoCell", for: indexPath) as? MemoCell else { return MemoCell() }
            cell.memoLabel.text = item
            return cell
        }
        
        
        return datasource
    }
}

