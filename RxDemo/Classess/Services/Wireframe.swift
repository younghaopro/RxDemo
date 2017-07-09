//
//  Wireframe.swift
//  RxDemo
//
//  Created by yanghao on 2017/7/9.
//  Copyright © 2017年 yanghao. All rights reserved.
//

import RxSwift

import UIKit

enum RetryResult {
    case retry
    case cancel
}

protocol Wireframe {
    func open(url: URL)
    func prompt<Action: CustomStringConvertible>(_  message: String, cancelAction: Action, actions: [Action]) -> Observable<Action>
}

class DefaultWireframe: Wireframe {
    static let shared = DefaultWireframe()

    func open(url: URL) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private static func rootViewController() -> UIViewController {
        return UIApplication.shared.keyWindow!.rootViewController!
    }

    static func presentAlert(_ message: String) {
        let aletView = UIAlertController(title: "RxDemo", message: message, preferredStyle: .alert)
        aletView.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { _ in }))
        rootViewController().present(aletView, animated: true, completion: nil)
    }

    func prompt<Action: CustomStringConvertible>(_ message: String, cancelAction: Action, actions: [Action]) -> Observable<Action> where Action : CustomStringConvertible {
        return Observable.create { observer in
            let alertView = UIAlertController(title: "RxDemo", message: message, preferredStyle: .alert)
            alertView.addAction(UIAlertAction(title: cancelAction.description, style: .cancel, handler: { (_) in
                observer.onNext(cancelAction)
            }))

            for action in actions {
                alertView.addAction(UIAlertAction(title: action.description, style: .default, handler: { (_) in
                    observer.onNext(action)
                }))
            }

            DefaultWireframe.rootViewController().present(alertView, animated: true, completion: nil)

            return Disposables.create {
                alertView.dismiss(animated: false, completion: nil)
            }
        }
    }
}
