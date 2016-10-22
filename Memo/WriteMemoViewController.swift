//
//  WriteMemoViewController.swift
//  Memo
//
//  Created by Leonard on 2016. 10. 20..
//  Copyright © 2016년 Leonard. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

extension UIViewController {
    func wrapNavigation() -> UINavigationController {
        let navigationController = UINavigationController(rootViewController: self)
        return navigationController
    }
}

@objc protocol WriteMemoViewControllerDelegate: NSObjectProtocol {
    @objc optional func memoGetController(picker: WriteMemoViewController, didFinishGetNewMemo memo: String)
    @objc optional func memoGetControllerDidCancel(picker: WriteMemoViewController)
}

class WriteMemoViewControllerDelegateProxy: DelegateProxy, DelegateProxyType, WriteMemoViewControllerDelegate {
    
    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        let userPickerController = object as! WriteMemoViewController
        userPickerController.delegate = delegate as? WriteMemoViewControllerDelegate
    }
    
    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        let userPickerController = object as! WriteMemoViewController
        return userPickerController.delegate
    }

}



class WriteMemoViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    weak var delegate: WriteMemoViewControllerDelegate?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rxAction()
        API.Baconipsum().subscribe(onNext: {[weak self] json in
            print("json: \(json)")
            let data: [String] = json as! [String]
            self?.textView.text = data[0]
        }).addDisposableTo(disposeBag)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

extension WriteMemoViewController {
    func rxAction() {
        self.navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.delegate?.memoGetControllerDidCancel?(picker: self)
        }).addDisposableTo(disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.delegate?.memoGetController?(picker: self, didFinishGetNewMemo: self.textView.text)
        }).addDisposableTo(disposeBag)
        
        NotificationCenter.default.rx.notification(.UIKeyboardDidShow).flatMap{ notification -> Observable<CGRect> in
            guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return Observable.empty() }
            return Observable.just(keyboardFrame)
        }.debounce(0.01, scheduler: MainScheduler.instance).bindNext { [weak self] frame in
            print("show",frame)
            self?.textView.contentInset = UIEdgeInsetsMake(0, 0, frame.size.height, 0)
        }.addDisposableTo(disposeBag)

        
        NotificationCenter.default.rx.notification(.UIKeyboardDidHide).flatMap{ notification -> Observable<CGRect> in
            print(notification)
            guard let keyboardFrame = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return Observable.empty() }
            return Observable.just(keyboardFrame)
        }.bindNext { [weak self]  frame in
            print("hide", frame)
            self?.textView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        }.addDisposableTo(disposeBag)
        
    }
}

func dismissViewController(viewController: UIViewController, animated: Bool) {
    if viewController.isBeingDismissed || viewController.isBeingPresented {
        DispatchQueue.main.async {
            dismissViewController(viewController: viewController, animated: animated)
        }
        
        return
    }
    
    if viewController.presentingViewController != nil {
        viewController.dismiss(animated: animated, completion: nil)
    }
}

extension Reactive where Base: WriteMemoViewController {
    var delegate: DelegateProxy {
        return WriteMemoViewControllerDelegateProxy.proxyForObject(base)
    }
    
    var didFinishGettingMemo: Observable<String> {
        return delegate
            .methodInvoked(#selector(WriteMemoViewControllerDelegate.memoGetController(picker:didFinishGetNewMemo:)))
            .map{ (a) in
                return a[1] as! String
        }
    }
    
    var didCancel: Observable<()> {
        return delegate.methodInvoked(#selector(WriteMemoViewControllerDelegate.memoGetControllerDidCancel(picker:))).map {
            _ in ()
        }
    }
    static func create(_ parent: UIViewController?, animated: Bool = true) -> Observable<WriteMemoViewController> {
        return Observable.create { [weak parent] observer in
            guard let writeMemoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "WriteMemoViewController") as? WriteMemoViewController else {
                return Disposables.create()
            }
            
            let dismissDisposable = writeMemoViewController.rx.didCancel.subscribe(onNext: {  [weak writeMemoViewController]  _ in
                guard let writeMemoViewController = writeMemoViewController else { return }
                dismissViewController(viewController: writeMemoViewController, animated: animated)
            })
            
            guard let parent = parent else {
                observer.on(.completed)
                return Disposables.create()
            }
            
            parent.present(writeMemoViewController.wrapNavigation(), animated: animated, completion: nil)
            observer.on(.next(writeMemoViewController))
            
            return CompositeDisposable(dismissDisposable, Disposables.create {
                dismissViewController(viewController: writeMemoViewController, animated: animated)
            })
        }
    }
}
