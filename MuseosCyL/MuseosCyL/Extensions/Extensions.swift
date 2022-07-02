//
//  Extensions.swift
//  MuseosCyL
//
//  Created by RAQUEL CHAMORRO GIGANTO on 30/09/2021.
//

import Foundation
import UIKit

extension String {

    func stripOutHtml() -> String? {
        do {
            guard let data = self.data(using: .unicode) else {
                return nil
            }
            let attributed = try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
            return attributed.string
        } catch {
            return nil
        }
    }
    
    func contains(insensitive other: String, range: Range<String.Index>? = nil, locale: Locale? = nil) -> Bool {
        return self.range(of: other, options: [.diacriticInsensitive, .caseInsensitive], range: range, locale: locale) != nil
    }

}

extension Double {
    func twoDecimals() -> Double{
        let stringValue = String(format: "%.2f", self/1000)
        return Double(stringValue)!
    }
}
