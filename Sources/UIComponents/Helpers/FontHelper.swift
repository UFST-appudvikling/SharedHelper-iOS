//
//  File.swift
//
//
//  Created by Nicolai Øyen Dam on 30/06/2021.
//

import SwiftUI

extension View {
    
    @ViewBuilder
    public func font(_ academyName: AcademyName, size: CGFloat) -> some View {
        self.font(.custom(academyName.rawValue, size: size))
    }
}
