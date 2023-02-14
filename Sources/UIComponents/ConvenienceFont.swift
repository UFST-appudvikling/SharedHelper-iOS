//
//  File.swift
//
//
//  Created by Nicolai Øyen Dam on 30/06/2021.
//
import UIKit
import SwiftUI

enum ConvenienceFont: CaseIterable, Identifiable, Hashable {
    var id: String {
        "\(self)"
    }
    case title1,
         title2,
         headline1,
         headline2,
         headline3,
         body1,
         body2,
         button1,
         label,
         input1,
         input3,
         caption,
         captionEmphasized
}

extension View {
    
    @ViewBuilder
    public func font(_ academyName: AcademyName, size: CGFloat) -> some View {
        self.font(.custom(academyName.rawValue, size: size))
    }
    
    @ViewBuilder
    func font(_ db_name: ConvenienceFont) -> some View {
//        runCode { registerFonts() }
        switch db_name {

        case .title1:
            self.font(Font.academySans(size: 34, type: .skat_black))
        case .title2:
            self.font(Font.academySans(size: 17, type: .skat_demiBold))
        case .headline1:
            self.font(Font.academySans(size: 20, type: .skat_demiBold))
        case .headline2:
            self.font(Font.academySans(size: 17, type: .skat_demiBold))
        case .headline3:
            self.font(Font.academySans(size: 15, type: .skat_demiBold))
        case .body1:
            self.font(Font.academySans(size: 17, type: .skat_regular))
        case .body2:
            self.font(Font.academySans(size: 15, type: .skat_regular))
        case .button1:
            self.font(Font.academySans(size: 17, type: .skat_demiBold))
        case .label:
            self.font(Font.academySans(size: 15, type: .skat_regular))
        case .input1:
            self.font(Font.academySans(size: 34, type: .skat_black))
        case .input3:
            self.font(Font.academySans(size: 22, type: .skat_black))
        case .caption:
            self.font(Font.academySans(size: 11, type: .skat_regular))
        case .captionEmphasized:
            self.font(Font.academySans(size: 11, type: .skat_demiBold))
        }
    }
}

func runCode(_ code: () -> Void) -> EmptyView {
    code()
    return EmptyView()
}

struct FontTestView: View, PreviewProvider {
    var body: some View {
        VStack {
            ForEach(ConvenienceFont.allCases) {
                Text("\($0)" as String).font($0)
            }
        }
    }
    static var previews: some View {
        ScrollView {
            FontTestView()
            FontTestView()
                .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
        }
    }
}
