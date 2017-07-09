//
//  GithubSignupViewModel1.swift
//  RxDemo
//
//  Created by yanghao on 2017/7/9.
//  Copyright © 2017年 yanghao. All rights reserved.
// swiftlint:disable large_tuple disable: vertical_parameter_alignment

import RxCocoa
import RxSwift

class GithubSignupViewModel1 {
    //outputs {

    let validateUsername: Observable<ValidationResult>
    let validatePassword: Observable<ValidationResult>
    let validatedPasswordRepeated: Observable<ValidationResult>

    // Is signup button enabled
    let signupEnabled: Observable<Bool>

    // Has user signed in
    let signedIn: Observable<Bool>

    // Is signing process in progress
    let signingIn: Observable<Bool>

    //}

    init(input: (
        username: Observable<String>,
        password: Observable<String>,
        repeatedPassword: Observable<String>,
        loginTaps: Observable<Void>
        ),
   dependency:(
        API: GitHubAPI,
        validationService: GitHubValidationService,
        wireframe: Wireframe
        )
        ) {
        let API = dependency.API
        let validationService = dependency.validationService
        let wireframe = dependency.wireframe

        validateUsername = input.username
            .flatMapLatest({ (username)  in
                return validationService.validationUsername(username)
                        .observeOn(MainScheduler.instance)
                        .catchErrorJustReturn(.failed(message: "Error contacting server"))
            })

        validatePassword = input.password
            .map({ (password) in
                return validationService.validatePassword(password)
            })
            .shareReplay(1)

        validatedPasswordRepeated = Observable.combineLatest(input.password, input.repeatedPassword, resultSelector: validationService.validateRepeatedPassword)
            .shareReplay(1)

        let signingIn =  ActivityIndicator()

        self.signingIn = signingIn.asObservable()

        let usernameAndPassword = Observable.combineLatest(input.username, input.password, resultSelector: { ($0, $1) })

        signedIn = input.loginTaps.withLatestFrom(usernameAndPassword)
            .flatMapLatest({ (username, password) in
                return API.signup(username, password: password)
                    .observeOn(MainScheduler.instance)
                    .catchErrorJustReturn(false)
                    .trackActivity(signingIn)
            })
            .flatMapLatest({ (loggedIn) -> Observable <Bool> in
                let message = loggedIn ? "Mock: Signed in to GitHub." :  "Mock: Sign in to GitHub failed"
                return wireframe.prompt(message, cancelAction: "OK", actions: [])
                    .map({ (_)  in
                        loggedIn
                    })
            })
            .shareReplay(1)
        signupEnabled = Observable.combineLatest(validateUsername, validatePassword, validatedPasswordRepeated, signingIn.asObservable()) { username, password, repeatPassword, signingIn in
                username.isValid &&
                password.isValid &&
                repeatPassword.isValid &&
                !signingIn
        }
        .distinctUntilChanged()
        .shareReplay(1)
    }
}
