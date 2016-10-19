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
    
    @IBOutlet weak var mixBarButtonItem: UIBarButtonItem!
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
        self.mixBarButtonItem.rx.tap.asObservable().subscribe(onNext: { [weak self] _ in
                self?.datasource.value = [SectionModel(model: 1, items:["memo9", "memo8", "memo7","memo6", "memo5", "memo4","memo3", "memo2", "memo1"])]
            }
        ).addDisposableTo(disposeBag)
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
