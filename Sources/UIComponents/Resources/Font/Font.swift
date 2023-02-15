//
//  File.swift
//  
//
//  Created by Nicolai Dam on 09/12/2021.
//

import SwiftUI
import UIKit


public class StyleBundle {}

class CurrentBundleFinder {}

public enum AcademyName: String, CaseIterable {
    case skat_black = "AcademySans-Black"
    case skat_regular = "AcademySans-Regular"
    case skat_bold = "AcademySans-Bold"
    case skat_demiBold = "AcademySans-Demibold"
    case skat_medium = "AcademySans-Medium"
}

extension Foundation.Bundle {
    static var myModule: Bundle = {
        /* The name of your local package, prepended by "LocalPackages_" */
        let bundleName = "SharedHelper-iOS_UIComponents"
        let candidates = [
            /* Bundle should be present here when the package is linked into an App. */
            Bundle.main.resourceURL,
            /* Bundle should be present here when the package is linked into a framework. */
            Bundle(for: CurrentBundleFinder.self).resourceURL,
            /* For command-line tools. */
            Bundle.main.bundleURL,
            /* Bundle should be present here when running previews from a different package (this is the path to "…/Debug-iphonesimulator/"). */
            Bundle(for: CurrentBundleFinder.self).resourceURL?.deletingLastPathComponent().deletingLastPathComponent(),
        ]
        for candidate in candidates {
            
            let bundlePath = candidate?.appendingPathComponent(bundleName + ".bundle")
            
            if let bundle = bundlePath.flatMap(Bundle.init(url:)) {
                return bundle
            }
        }
        fatalError("unable to find bundle named \(bundleName)")
    }()
}


func fontsURLs() -> [URL] {
    let bundle = Bundle.myModule
    var fileNames: [String] = []
    for value in AcademyName.allCases {
        fileNames.append(value.rawValue)
    }
    
    return fileNames.map { bundle.url(forResource: $0, withExtension: "otf")! }
}

extension UIFont {
    static func register(from url: URL) throws {
        guard let fontDataProvider = CGDataProvider(url: url as CFURL) else {
            fatalError()
        }
        let font = CGFont(fontDataProvider)!
        var error: Unmanaged<CFError>?
        guard CTFontManagerRegisterGraphicsFont(font, &error) else {
            throw error!.takeUnretainedValue()
        }
    }
}

private var didRegisterfonts = false
public func registerFonts() {
    guard !didRegisterfonts else { return }
    didRegisterfonts = true
    do {
        try fontsURLs().forEach { try UIFont.register(from: $0) }
    } catch {
        print(error)
    }
}

public extension Font {
    static func academySans(size: CGFloat, type: AcademyName) -> Font {
        registerFonts()
        return Font.custom(type.rawValue, size: size)
    }
}

extension View {
    
    @ViewBuilder
    func font(_ academyName: AcademyName, size: CGFloat) -> some View {
        self.font(.custom(academyName.rawValue, size: size))
    }
}
