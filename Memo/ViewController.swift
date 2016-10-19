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
    
    var datasource: Variable<[SectionModel<Int,String>]> = Variable([SectionModel(model: 1, items:["memo1", "memo2", "memo3","memo4", "memo5", "memo6","memo7", "memo8", "memo9"])])
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
extension ViewController {
    func rxAction() {
        self.navigationItem.rightBarButtonItem?.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
            guard let weakSelf = self else { return }
            guard var oldItems = weakSelf.datasource.value.first?.items else { return }
            let newMemoText = "memo\(oldItems.count + 1)"
            oldItems.append(newMemoText)
            let newSectionModel = SectionModel(model: 1, items: oldItems)
            weakSelf.datasource.value = [newSectionModel]
            }
        ).addDisposableTo(disposeBag)
        
        
        
        
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
    
    func bindDataSource() {
        
        datasource.asObservable().bindTo( collectionView.rx.items(dataSource: createDatasource())).addDisposableTo(disposeBag)
    }
    
    func createDatasource() -> RxCollectionViewSectionedReloadDataSource<SectionModel<Int,String>> {
        let datasource = RxCollectionViewSectionedReloadDataSource<SectionModel<Int,String>>()

        
        datasource.configureCell = { datasource, collectionView, indexPath, item in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemoCell", for: indexPath) as? MemoCell else { return MemoCell() }
            cell.memoLabel.text = "\(indexPath.row+1): \(item)"
            return cell
        }
        
        
        return datasource
    }
}
