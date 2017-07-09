//
//  CLLocationManager+Rx.swift
//  RxDemo
//
//  Created by yanghao on 2017/7/9.
//  Copyright © 2017年 yanghao. All rights reserved.
// swiftlint:disable line_length
//

import CoreLocation

import RxCocoa
import RxSwift

extension Reactive where Base: CLLocationManager {

    public var delegate: DelegateProxy {
        return RxCLLocationManagerDelegateProxy.proxyForObject(base)
    }

    public var didUpdateLocations: Observable<[CLLocation]> {
        guard let delegate = delegate as? RxCLLocationManagerDelegateProxy else {
            return Observable<[CLLocation]>.empty()
        }
        return delegate.didUpdateLocationsSubject.asObserver()

    }

    public var didFailWithError: Observable<Error> {
        guard let delegate = delegate as? RxCLLocationManagerDelegateProxy else {
            return Observable<Error>.empty()
        }
        return delegate.didFailWithErrorSubject.asObserver()
    }

    public var didFinishDeferredUpdatesWithError: Observable<Error?> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFinishDeferredUpdatesWithError:)))
            .map({ value  in
                return try castOptionalOrThrow(Error.self, value[1])
            })
    }

    public var didPauseLocationUpdates: Observable<Void> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManagerDidPauseLocationUpdates(_:)))
            .map { _ in
                return()
            }
    }

    public var didChangeAuthorizationStatus: Observable<CLAuthorizationStatus> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didChangeAuthorization:)))
                .map({ value  in
                    let number = try castoOrThrow(NSNumber.self, value[1])
                    return CLAuthorizationStatus(rawValue: Int32(number.intValue)) ?? .notDetermined
                })
    }
}

fileprivate func castoOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T {
    guard let resultVlue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return resultVlue
}
fileprivate func  castOptionalOrThrow<T>(_ resultType: T.Type, _ object: Any) throws -> T? {
    if NSNull().isEqual(object) {
        return nil
    }
    guard let resultValue = object as? T else {
        throw RxCocoaError.castingError(object: object, targetType: resultType)
    }
    return resultValue
}
