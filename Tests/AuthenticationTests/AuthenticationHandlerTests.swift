//
//  File.swift
//  
//
//  Created by Nicolai Dam on 31/05/2023.
//

import AuthenticationServices
import XCTest

@testable import Authentication
@testable import SecurityHandler

@MainActor
final class AuthenticationHandlerTests: XCTestCase {
    
    /// Testing that verifier and challenge are generated when the AuthenticationHandler is initialised
    func test_pkceGeneration() {
        
        var generateCodeChallengeInput: String?
        
        let pkceVerifier = "CodeVerifier"
        let pkcChallenge = "Challenge"
        
        let pkceClient: PKCEClient = .init(
            generateCodeVerifier: { pkceVerifier },
            generateCodeChallenge: { input in
                generateCodeChallengeInput = input
                return pkcChallenge
            }
        )
        
        /// Initalisation of AuthenticatoinHandler object
        let initialState = makeInitialState(pkceClient: pkceClient)
        
        /// Testing that the input in the generateCodeChallenge func corresponds to the pkceVerifier
        XCTAssertEqual(generateCodeChallengeInput!, pkceVerifier)
        
        /// Testing that codeVerifier and codeChallenge in the AuthenticationHandler equals the responses from the pkceClient
        XCTAssertEqual(initialState.pkceVariables.codeVerifier, pkceVerifier)
        XCTAssertEqual(initialState.pkceVariables.codeChallenge, pkcChallenge)
    }

    /// Testing that the authorization url generation that will be used in ASAuthenticationSession
    func test_AuthorizationURLStringGeneration() {
        
        let liveInput = AuthenticationHandler.LiveLoginInput(
            configuration: .mock,
            contextProvider: ASPresentationAnchor(),
            tokenIdentifier: "tokenIdentifier"
        )
        let mockedPKCEChallenge = "mockedChallenge"
        
        let actualURLString = createAuthorizationURL(input: liveInput, codeChallenge: mockedPKCEChallenge)!.absoluteString
        let expectedURLString = "https://test.comauthorize?client_id=client&redirect_uri=scheme:/&response_type=code&scope=scope1%20scope2&code_challenge_method=S256&code_challenge=mockedChallenge"
        
        XCTAssertEqual(actualURLString, expectedURLString)
    }

    /// Testing the fetchToken method business logic when there is no token in the keychain
    /// We expect the ASAuthenticationSession is presented and token to be fetched afterwards
    func test_fetchToken_noTokenInKeychain() async throws {
        
        var savedToken: String?
        let getTokenResponse = AuthenticationHandler.TokenModel.mockValidToken
        let date: Date = .init(timeIntervalSince1970: 0)
        
        let keyChainClient: KeychainClient = .init(
            getString: { _ in nil },
            save: { value, identifier in
                savedToken = value
                return true
            },
            remove: { _ in true }
        )
        
        let initialState = makeInitialState(keychainClient: keyChainClient, date: date, pkceClient: .empty)
        initialState.apiClient.getToken = { _ in return getTokenResponse }
        initialState.apiClient.getAuthorizationCode = { _ in return .success("code") }
 
        let (token, source) = try await initialState.fetchToken()

        XCTAssertEqual(savedToken, token.wrap(now: date), getTokenResponse.wrap(now: date))
        XCTAssertEqual(source, .loginSheet)
    }
    
    /// Testing the fetchToken method when access token is valid
    /// We expect the access token is returned
    func test_fetchToken_accessTokenValid() async throws {

        var tokenIdentifierUsedInKeyChain: String?
        let now: Date = .init(timeIntervalSince1970: 10)
        let tokenString = "accesstoken\trefreshtoken\ttokentype\t60.0\t299.0"
        
        let initialState = makeInitialState(date: now, pkceClient: .empty)
        initialState.keychainClient.getString = { tokenIdentifier in
            tokenIdentifierUsedInKeyChain = tokenIdentifier
            return tokenString
        }

        let (token, source) = try await initialState.fetchToken()

        XCTAssertEqual(token.accessToken, "accesstoken")
        XCTAssertEqual(token.refreshToken, "refreshtoken")
        XCTAssertEqual(token.tokenType, "tokentype")
        XCTAssertEqual(token.expiresIn, 50)
        XCTAssertEqual(token.refreshExpiresIn, 289)
        XCTAssertEqual(source, .keychain)
        guard case let .live(input) = initialState.loginType else { fatalError() }
        XCTAssertEqual(tokenIdentifierUsedInKeyChain, input.tokenIdentifier)
    }
    /// Testing the fetchToken method when access token is invalid but refresh token is valid
    /// We expect the access token is refreshed silently using the valid refresh token
    func test_fetchToken_accessTokenInValid_refreshTokenValid() async throws {
        
        var tokenIdentifierUsedInKeyChain: String?
        let now: Date = .init(timeIntervalSince1970: 70)
        let tokenString = "accesstoken\trefreshtoken\ttokentype\t60.0\t299.0"
        
        let tokenReturnedAfterRefresh: AuthenticationHandler.TokenModel = .mockValidToken
        
        var actualTokenStringSavedInKeychain: String?
        let expectedStringSavedInKeychain = "sdlkfjsaldkfjnlksdnsd\tdsjkhbfsdjhfbsdjhfsb\ttokenType\t130.0\t369.0"
        
        let initialState = makeInitialState(date: now, pkceClient: .empty)
        initialState.apiClient.getToken = { input in tokenReturnedAfterRefresh }
        initialState.keychainClient.getString = { tokenIdentifier in
            tokenIdentifierUsedInKeyChain = tokenIdentifier
            return tokenString
        }
        initialState.keychainClient.save =  { value, tokenIdentifier in
            actualTokenStringSavedInKeychain = value
            return true
        }
        initialState.keychainClient.remove = { _ in true }

        let (token, source) = try await initialState.fetchToken()

        XCTAssertEqual(source, .refresh)
        XCTAssertEqual(token, tokenReturnedAfterRefresh)
        guard case let .live(input) = initialState.loginType else { fatalError() }
        XCTAssertEqual(tokenIdentifierUsedInKeyChain, input.tokenIdentifier)
        XCTAssertEqual(actualTokenStringSavedInKeychain!, expectedStringSavedInKeychain)
    }

    /// Testing the fetchToken method when both access token and refresh token is invalid
    /// We expect the ASAuthenticationSession is presented
    func test_fetchToken_accessTokenIsInValid_refreshTokenInvalid() async throws {
        
        var tokenIdentifierUsedInKeyChain: String?
        let now: Date = .init(timeIntervalSince1970: 400)
        let tokenString = "accesstoken\trefreshtoken\ttokentype\t60.0\t299.0"
        
        let tokenReturnedAfterRefresh: AuthenticationHandler.TokenModel = .mockValidToken
                
        let initialState = makeInitialState( date: now, pkceClient: .empty)
        initialState.apiClient.getToken = { input in tokenReturnedAfterRefresh }
        initialState.apiClient.getAuthorizationCode = { input in return .success("code") }
        initialState.keychainClient.getString = { tokenIdentifier in
            tokenIdentifierUsedInKeyChain = tokenIdentifier
            return tokenString
        }
        initialState.keychainClient.save = { value, tokenIdentifier in
            return true
        }
        initialState.keychainClient.remove = { _ in true }

        let (token, source) = try await initialState.fetchToken()

        XCTAssertEqual(source, .loginSheet)
        XCTAssertEqual(token, tokenReturnedAfterRefresh)
        guard case let .live(input) = initialState.loginType else { fatalError() }
        XCTAssertEqual(tokenIdentifierUsedInKeyChain, input.tokenIdentifier)
    }
    

    /// Testing the checkIfTokenExist method when there is a valid token in the keychain
    /// We expect the access token is returned
    func test_checkIfTokenExist_ValidAccessToken() throws {
                
        let tokenIdentifier = "tokenIdentifier"
        let date: Date = .init(timeIntervalSince1970: 0)
        
        let initialState: AuthenticationHandler = makeInitialState(
            date: date,
            pkceClient: .empty,
            tokenIdentifier: tokenIdentifier
        )
        initialState.keychainClient.getString = { tokenIdentifier in "accesstoken\trefreshtoken\ttokentype\t60.0\t299.0" }
        let token = initialState.checkTokenIfExistOnLive()
        
        /// Testing that given tokenIdentifier is removed from the keychain when logout() is called
        XCTAssertEqual(token?.wrap(now: date), "accesstoken\trefreshtoken\ttokentype\t60.0\t299.0")
    }
    /// Testing the checkIfTokenExist method when there is an invalid token in the keychain
    /// We expect nil is returned
    func test_checkIfTokenExist_InValidAcessToken() throws {

        let tokenIdentifier = "tokenIdentifier"
        let date: Date = .init(timeIntervalSince1970: 0)
        
        let initialState: AuthenticationHandler = makeInitialState(
            date: date,
            pkceClient: .empty,
            tokenIdentifier: tokenIdentifier
        )
        initialState.keychainClient.getString = { tokenIdentifier in nil }
        
        let token = initialState.checkTokenIfExistOnLive()
        
        /// Testing that given tokenIdentifier is removed from the keychain when logout() is called
        XCTAssertNil(token)
    }

    /// Testing happy flow of loginByShowingSheet method
    /// We expect a token is returned
    func test_loginByShowingSheet_success() async throws {
        
        let returnedToken: AuthenticationHandler.TokenModel = .mockValidToken
        
        
        let initialState = makeInitialState(pkceClient: .empty, sheetIsActive: false)
        initialState.apiClient.getToken = { input in returnedToken }
        initialState.apiClient.getAuthorizationCode =  { input in return .success("code") }
        initialState.keychainClient.save = { identifier, value in true }
        initialState.keychainClient.remove = { _ in true }
        
        // Ensure the initial value of sheetIsActive is false
        XCTAssertFalse(initialState.sheetIsActive)
        
        // Create an expectation to wait for the asynchronous task to complete
        let expectation = XCTestExpectation(description: "loginByShowingSheetOnLive completed")
        
        Task {
            let token = try await initialState.loginByShowingSheetOnLive()
            XCTAssertEqual(token, returnedToken)
            XCTAssertTrue(initialState.sheetIsActive)
        }
        expectation.fulfill()

        XCTAssertFalse(initialState.sheetIsActive)
    }

    /// Testing error in the loginByShowingSheet method
    /// We expect an error is thrown
    func test_loginByShowingSheet_error() async throws {

        let returnedError: AuthenticationHandler.CustomError = .decodingError
        var catchedError: AuthenticationHandler.CustomError?
                
        let initialState = makeInitialState(pkceClient: .empty, sheetIsActive: false)
        initialState.apiClient.getAuthorizationCode = { input in
            .failure(returnedError)
    }
        
        // Ensure the initial value of sheetIsActive is false
        XCTAssertFalse(initialState.sheetIsActive)
        
        // Create an expectation to wait for the asynchronous task to complete
        let expectation = XCTestExpectation(description: "loginByShowingSheetOnLive completed")
        
        Task {
            do {
                _ = try await initialState.loginByShowingSheetOnLive()
                XCTAssertTrue(initialState.sheetIsActive)
            } catch let error {
                catchedError = error as? AuthenticationHandler.CustomError
            }
            XCTAssertEqual(catchedError, returnedError)
        }
        expectation.fulfill()

        XCTAssertFalse(initialState.sheetIsActive)
    }

    /// Testing that an error is thrown if sheet is actve and the loginByShowingSheetOnLive func is invoked
    /// Note that loginByShowingSheetOnLive can be called from fetchToken
    func test_loginByShowingSheetOnLive_sheetAlreadyActive() async throws {
        
        var returnedError: AuthenticationHandler.CustomError?
        let actualError: AuthenticationHandler.CustomError = .internalError("Sheet is already active")
        let initialState = makeInitialState(pkceClient: .empty, sheetIsActive: true)
        
        do {
            try await initialState.loginByShowingSheetOnLive()
        } catch let error {
            returnedError = error as? AuthenticationHandler.CustomError
        }
        
        /// Expecing an internal error is thrown with the string input Sheet is already active since sheetIsActive in the AuthenicationHandler is true
        XCTAssertEqual(actualError, returnedError)
    }
    
    func test_logout() throws {

        let tokenIdentifier = "tokenIdentifier"
        var removedTokenIdentifier: String?
        
        let initialState: AuthenticationHandler = makeInitialState(
            pkceClient: .empty,
            tokenIdentifier: tokenIdentifier
        )
        initialState.keychainClient.remove = { identifier in
            removedTokenIdentifier = identifier
            return true
        }
        initialState.logout()
        
        /// Testing that given tokenIdentifier is removed from the keychain when logout() is called
        XCTAssertEqual(tokenIdentifier, removedTokenIdentifier!)
    }
}

