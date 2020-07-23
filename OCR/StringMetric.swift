//
//  StringMetric.swift
//  OCR
//
//  Created by Audhy Virabri Kressa on 10/07/20.
//  Copyright © 2020 Audhy Virabri Kressa. All rights reserved.
//

import Foundation

extension String {
    /// Get distance between target. (alias of `distanceJaroWinkler(between:)`.)
    /// - Parameter target: The target `String`.
    /// - Returns: The Jaro-Winkler distance between the receiver and `target`.
    public func distance(between target: String) -> Double {
        return distanceJaroWinkler(between: target)
    }

    /// Get Damerau-Levenshtein distance.
    ///
    /// Reference <https://en.wikipedia.org/wiki/Damerau%E2%80%93Levenshtein_distance#endnote_itman#Distance_with_adjacent_transpositions>
    /// - Parameter target: The target `String`.
    /// - Returns: The Damerau-Levenshtein distance between the receiver and `target`.
    public func distanceDamerauLevenshtein(between target: String) -> Int {
        let selfCount = self.count
        let targetCount = target.count

        if self == target {
            return 0
        }
        if selfCount == 0 {
            return targetCount
        }
        if targetCount == 0 {
            return selfCount
        }

        var da: [Character: Int] = [:]

        var d = Array(repeating: Array(repeating: 0, count: targetCount + 2), count: selfCount + 2)

        let maxdist = selfCount + targetCount
        d[0][0] = maxdist
        for i in 1...selfCount + 1 {
            d[i][0] = maxdist
            d[i][1] = i - 1
        }
        for j in 1...targetCount + 1 {
            d[0][j] = maxdist
            d[1][j] = j - 1
        }

        for i in 2...selfCount + 1 {
            var db = 1

            for j in 2...targetCount + 1 {
                let k = da[target[j - 2]!] ?? 1
                let l = db

                var cost = 1
                if self[i - 2] == target[j - 2] {
                    cost = 0
                    db = j
                }

                let substition = d[i - 1][j - 1] + cost
                let injection = d[i][j - 1] + 1
                let deletion = d[i - 1][j] + 1
                let selfIdx = i - k - 1
                let targetIdx = j - l - 1
                let transposition = d[k - 1][l - 1] + selfIdx + 1 + targetIdx

                d[i][j] = Swift.min(
                    substition,
                    injection,
                    deletion,
                    transposition
                )
            }

            da[self[i - 2]!] = i
        }

        return d[selfCount + 1][targetCount + 1]
    }


    /// Get Jaro-Winkler distance.
    ///
    /// (Score is normalized such that 0 equates to no similarity and 1 is an exact match).
    ///
    /// Reference <https://en.wikipedia.org/wiki/Jaro%E2%80%93Winkler_distance>
    /// - Parameter target: The target `String`.
    /// - Returns: The Jaro-Winkler distance between the receiver and `target`.
    public func distanceJaroWinkler(between target: String) -> Double {
        var stringOne = self
        var stringTwo = target
        if stringOne.count > stringTwo.count {
            stringTwo = self
            stringOne = target
        }

        let stringOneCount = stringOne.count
        let stringTwoCount = stringTwo.count

        if stringOneCount == 0 && stringTwoCount == 0 {
            return 1.0
        }

        let matchingDistance = stringTwoCount / 2
        var matchingCharactersCount: Double = 0
        var transpositionsCount: Double = 0
        var previousPosition = -1

        // Count matching characters and transpositions.
        for (i, stringOneChar) in stringOne.enumerated() {
            for (j, stringTwoChar) in stringTwo.enumerated() {
                if max(0, i - matchingDistance)..<min(stringTwoCount, i + matchingDistance) ~= j {
                    if stringOneChar == stringTwoChar {
                        matchingCharactersCount += 1
                        if previousPosition != -1 && j < previousPosition {
                            transpositionsCount += 1
                        }
                        previousPosition = j
                        break
                    }
                }
            }
        }

        if matchingCharactersCount == 0.0 {
            return 0.0
        }

        // Count common prefix (up to a maximum of 4 characters)
        let commonPrefixCount = min(max(Double(self.commonPrefix(with: target).count), 0), 4)

        let jaroSimilarity = (matchingCharactersCount / Double(stringOneCount) + matchingCharactersCount / Double(stringTwoCount) + (matchingCharactersCount - transpositionsCount) / matchingCharactersCount) / 3

        // Default is 0.1, should never exceed 0.25 (otherwise similarity score could exceed 1.0)
        let commonPrefixScalingFactor = 0.1

        return jaroSimilarity + commonPrefixCount * commonPrefixScalingFactor * (1 - jaroSimilarity)
    }
}
