//
//  ViewModel.swift
//  Pokemon API
//
//  Created by frank on 5/3/25.
//

import Foundation

class ViewModel: ObservableObject {
    // MARK: - Fuzzy Name Matching and Utility

    func levenshtein(_ lhs: String, _ rhs: String) -> Int {
        let lhs = Array(lhs.lowercased())
        let rhs = Array(rhs.lowercased())

        var dp = Array(repeating: Array(repeating: 0, count: rhs.count + 1), count: lhs.count + 1)

        for i in 0...lhs.count {
            dp[i][0] = i
        }
        for j in 0...rhs.count {
            dp[0][j] = j
        }

        for i in 1...lhs.count {
            for j in 1...rhs.count {
                if lhs[i-1] == rhs[j-1] {
                    dp[i][j] = dp[i-1][j-1]
                } else {
                    dp[i][j] = min(
                        dp[i-1][j] + 1,
                        dp[i][j-1] + 1,
                        dp[i-1][j-1] + 1
                    )
                }
            }
        }

        return dp[lhs.count][rhs.count]
    }
    // this function performs the name differential against the array below
    func findClosestPokemonName(for input: String, in names: [String]) -> String? {
        let threshold = 3
        let sortedNames = names.map { ($0, levenshtein(input, $0)) }
            .sorted { $0.1 < $1.1 }

        if let bestMatch = sortedNames.first, bestMatch.1 <= threshold {
            return bestMatch.0
        } else {
            return nil
        }
    }
    // in order to let the fuzzy search function work the way that it does I needed to create an array of all pokemon names. the search then runs the typed name in search against the database and finds through character/string matching the best result. This could be tweaked to provide more results, or better results.
    func fetchAllPokemonNames() async -> [String] {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon?limit=10000") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(PokemonList.self, from: data)
            return decoded.results.map { $0.name }
        } catch {
            return []
        }
    }
    //this is pulling the sprite for the fuzzy search function
    func fetchPokemonSprite(for name: String) async -> String? {
        guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(name.lowercased())") else { return nil }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoded = try JSONDecoder().decode(Pokemon.self, from: data)
            return decoded.sprites.front_default
        } catch {
            return nil
        }
    }

}
