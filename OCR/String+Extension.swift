//
//  String+Extension.swift
//  OCR
//
//  Created by Audhy Virabri Kressa on 10/07/20.
//  Copyright © 2020 Audhy Virabri Kressa. All rights reserved.
//

extension String {
    func index(_ i: Int) -> String.Index {
        if i >= 0 {
            return self.index(self.startIndex, offsetBy: i)
        } else {
            return self.index(self.endIndex, offsetBy: i)
        }
    }

    subscript(i: Int) -> Character? {
        if i >= count || i < -count {
            return nil
        }

        return self[index(i)]
    }

    subscript(r: Range<Int>) -> String {
        return String(self[index(r.lowerBound)..<index(r.upperBound)])
    }
}
