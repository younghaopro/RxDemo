//
//  GeolocationViewController.swift
//  RxDemo
//
//  Created by yanghao on 2017/7/9.
//  Copyright © 2017年 yanghao. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CoreLocation

private extension Reactive where Base: UILabel {
    var coordinates: UIBindingObserver<Base, CLLocationCoordinate2D> {
        return UIBindingObserver(UIElement: base, binding: { (label, location) in
            label.text = "Lat: \(location.latitude)\nLon: \(location.longitude)"
        })
    }
}
class GeolocationViewController: ViewController {

    @IBOutlet var noGeolocationView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var label: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(noGeolocationView)
        let geolocationService = GeolocationService.instance
        geolocationService.authorized
            .drive(noGeolocationView.rx.isHidden)
            .disposed(by: disposeBag)

        geolocationService.location
            .drive(label.rx.coordinates)
            .disposed(by: disposeBag)

        button.rx.tap
            .bind { [weak self] in
                self?.openAppPerferences()
            }
            .disposed(by: disposeBag)

        button2.rx.tap
            .bind { [weak self] in
                self?.openAppPerferences()
            }
            .disposed(by: disposeBag)
    }
    private func openAppPerferences() {
        UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!)
    }
}
