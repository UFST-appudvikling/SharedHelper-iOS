//
//  File.swift
//  
//
//  Created by Nicolai Dam on 04/06/2023.
//

import AuthenticationServices

final class AuthenticationHandlerObject: NSObject {
    
    let contextProvider: ASPresentationAnchor
    
    init(contextProvider: ASPresentationAnchor) {
        self.contextProvider = contextProvider
    }
}

extension AuthenticationHandlerObject: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        return self.contextProvider
  }
}
