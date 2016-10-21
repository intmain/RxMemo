//
//  PracticeViewController.swift
//  Memo
//
//  Created by Leonard on 2016. 10. 22..
//  Copyright © 2016년 Leonard. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class PracticeViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var textLabel: UILabel!
    let disposeBag = DisposeBag()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        textField.rx.text.asObservable().bindTo(textLabel.rx.text).addDisposableTo(disposeBag)
        
        Observable.from([2,3,41,23]).subscribe { event in
            switch event {
            case let .next(value):
                print("value : \(value)")
            case let .error(error):
                print("error : \(error)")
            case .completed:
                print("complete")
                
            }
        }.addDisposableTo(disposeBag)
        
        Observable.of([2,3,41,23]).subscribe { event in
            switch event {
            case let .next(value):
                print("value : \(value)")
            case let .error(error):
                print("error : \(error)")
            case .completed:
                print("complete")
                
            }
        }.addDisposableTo(disposeBag)
        
        Observable.create { (observer: AnyObserver<Int>) -> Disposable in
            observer.onNext(4)
            observer.onNext(4)
            observer.onNext(4)
            observer.onCompleted()
            return Disposables.create {
                
            }
        }
        .subscribe{ event in
            print(event)
        }
        .addDisposableTo(disposeBag)
        
        let variable = Variable<Int>(0)
        variable.asObservable().subscribe { event in
            print("variable: \(event)")
            }.addDisposableTo(disposeBag)
        
        variable.value = 3
        variable.value = 13
        variable.value = 135

        let publishSubject = PublishSubject<Int>()
        publishSubject.subscribe { event in
            print("subject: \(event)")
        }.addDisposableTo(disposeBag)
        
        publishSubject.onNext(5)
        publishSubject.onNext(15)
        publishSubject.onNext(115)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
