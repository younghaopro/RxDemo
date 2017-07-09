//
//  RxCLLocationManagerDelegateProxy.swift
//  RxDemo
//
//  Created by yanghao on 2017/7/9.
//  Copyright © 2017年 yanghao. All rights reserved.
//

import CoreLocation

import RxSwift
import RxCocoa

class RxCLLocationManagerDelegateProxy: DelegateProxy, CLLocationManagerDelegate, DelegateProxyType {

    internal lazy var didUpdateLocationsSubject = PublishSubject<[CLLocation]>()
    internal lazy var didFailWithErrorSubject = PublishSubject<Error>()

    class func currentDelegateFor(_ object: AnyObject) -> AnyObject? {
        if let locationManager: CLLocationManager = object as? CLLocationManager {
            return locationManager.delegate
        }
        return nil
    }

    class func setCurrentDelegate(_ delegate: AnyObject?, toObject object: AnyObject) {
        guard let locationManager: CLLocationManager = object as? CLLocationManager else {
            return
        }
        guard let delegate = delegate else {
            return locationManager.delegate = nil

        }
        locationManager.delegate = delegate as? CLLocationManagerDelegate
    }

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        _forwardToDelegate?.locationManager(manager, didUpdateLocations: locations)
        didUpdateLocationsSubject.onNext(locations)
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        _forwardToDelegate?.locationManager(manager, didFailWithError: error)
        didFailWithErrorSubject.onError(error)
    }
    deinit {
        self.didUpdateLocationsSubject.onCompleted()
        self.didFailWithErrorSubject.onCompleted()
    }
}
