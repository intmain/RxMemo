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
    
    var datasource: Variable<[SectionModel<Int,String>]> = {
        var items = ["Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ", "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ", "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ","Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ", "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ", "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also  the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ","Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ", "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also ", "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also "]
        return Variable([SectionModel(model: 1, items: items)])
    }()
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
            let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WriteMemoViewController") as! WriteMemoViewController
            viewController.delegate = self
            self?.present(viewController.wrapNavigation(), animated: true, completion: nil)
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
}

// MARK: - CollectionView
extension ViewController {
    
    func bindDataSource() {
        
        datasource.asObservable().bindTo( collectionView.rx.items(dataSource: createDatasource())).addDisposableTo(disposeBag)
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
    
    func addCell(text: String) {
        guard var newItems = self.datasource.value.first?.items else { return }
        newItems.append(text)
        let newSectionModel = SectionModel(model: 1, items: newItems)
        self.datasource.value = [newSectionModel]
    }
}

extension ViewController: WriteMemoViewControllerDelegate {
    func memoGetController(picker: WriteMemoViewController, didFinishGetNewMemo memo: String) {
        addCell(text: memo)
    }
    
    func memoGetControllerDidCancel(picker: WriteMemoViewController) {
        
    }
}
