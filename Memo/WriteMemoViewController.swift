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

class WriteMemoViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    weak var delegate: WriteMemoViewControllerDelegate?
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        rxAction()
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

extension WriteMemoViewController {
    func rxAction() {
        self.navigationItem.leftBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.delegate?.memoGetControllerDidCancel?(picker: self)
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
        
        self.navigationItem.rightBarButtonItem?.rx.tap.subscribe(onNext: { [unowned self] _ in
            self.delegate?.memoGetController?(picker: self, didFinishGetNewMemo: self.textView.text)
            self.dismiss(animated: true, completion: nil)
        }).addDisposableTo(disposeBag)
    }
}
