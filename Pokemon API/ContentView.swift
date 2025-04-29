//
//  ContentView.swift
//  Pokemon API
//
//  Created by Erik Woods on 4/28/25.
//

import SwiftUI

struct Pokemon: Decodable {
    let name: String
    let height: Int
    let weight: Int
    let stats: [Stat]
    let sprites: Sprites
    let species: SpeciesURL
}

struct Stat: Decodable {
    let base_stat: Int
    let stat: StatInfo
}

struct StatInfo: Decodable {
    let name: String
}

struct SpeciesURL: Decodable {
    let url: String
}

struct Sprites: Decodable {
    let front_default: String
}

struct Species: Decodable {
    let evolution_chain: EvolutionChain
}

struct EvolutionChain: Decodable {
    let url: String
}

struct EvolutionDetail: Decodable {
    let chain: Chain
}

struct Chain: Decodable {
    let evolves_to: [Chain]
    let evolution_details: [EvolutionDetailInfo]
    let species: SpeciesInfo
}

struct EvolutionDetailInfo: Decodable {
    let min_level: Int?
    let trigger: Trigger
    let item: ItemInfo?
}

struct Trigger: Decodable {
    let name: String
}

struct ItemInfo: Decodable {
    let name: String
}

struct SpeciesInfo: Decodable {
    let name: String
}

struct ContentView: View {
    @State private var pokemonName = ""
    @State private var pokemon: Pokemon?
    @State private var errorMessage: String?
    @State private var hp: Int?
    @State private var attack: Int?
    @State private var evolutionLevel: String = "N/A"
    @State private var evolutionMethod: String = ""
    @State private var allPokemonNames: [String] = []
    @State private var correctedName: String?
    @State private var evolvesFrom: String?
    @State private var evolvesTo: String?

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Pokémon name", text: $pokemonName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Search") {
                    fetchPokemon(named: pokemonName.lowercased())
                }

                if let corrected = correctedName {
                    Text("Did you mean \(corrected.capitalized)?")
                        .foregroundColor(.orange)
                        .font(.subheadline)
                }

                if let pokemon = pokemon {
                    VStack(spacing: 10) {
                        Text(pokemon.name.capitalized)
                            .font(.largeTitle)

                        AsyncImage(url: URL(string: pokemon.sprites.front_default)) { image in
                            image.resizable()
                        } placeholder: {
                            ProgressView()
                        }
                        .frame(width: 120, height: 120)

                        Text("Height: \(pokemon.height)")
                        Text("Weight: \(pokemon.weight)")
                        if let hp = hp {
                            Text("HP: \(hp)")
                        }
                        if let attack = attack {
                            Text("Attack: \(attack)")
                        }
                        Text("Evolution: \(evolutionLevel)")
                        if !evolutionMethod.isEmpty {
                            Text("How to Evolve: \(evolutionMethod)")
                        }
                        if let from = evolvesFrom {
                            Text("Evolved From: \(from)")
                        }
                        if let to = evolvesTo {
                            Text("Evolves To: \(to)")
                        }
                    }
                    .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                }

                Spacer()
            }
            .navigationTitle("Pokémon Search")
        }
    }

    func fetchPokemon(named name: String) {
        Task {
            if allPokemonNames.isEmpty {
                allPokemonNames = await fetchAllPokemonNames()
            }

            var searchName = name.lowercased()
            correctedName = nil
            if !allPokemonNames.contains(searchName) {
                if let corrected = findClosestPokemonName(for: searchName, in: allPokemonNames) {
                    correctedName = corrected
                    searchName = corrected
                }
            }

            guard let url = URL(string: "https://pokeapi.co/api/v2/pokemon/\(searchName)") else {
                errorMessage = "Invalid URL"
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let decodedPokemon = try JSONDecoder().decode(Pokemon.self, from: data)
                self.pokemon = decodedPokemon
                self.hp = decodedPokemon.stats.first(where: { $0.stat.name == "hp" })?.base_stat
                self.attack = decodedPokemon.stats.first(where: { $0.stat.name == "attack" })?.base_stat

                // Fetch evolution data
                let (speciesData, _) = try await URLSession.shared.data(from: URL(string: decodedPokemon.species.url)!)
                let species = try JSONDecoder().decode(Species.self, from: speciesData)

                let (evolutionData, _) = try await URLSession.shared.data(from: URL(string: species.evolution_chain.url)!)
                let evolution = try JSONDecoder().decode(EvolutionDetail.self, from: evolutionData)

                func findEvolutionContext(in chain: Chain, previous: (species: String, details: [EvolutionDetailInfo])?) -> (from: String?, to: String?, details: EvolutionDetailInfo?)? {
                    if chain.species.name == searchName {
                        let next = chain.evolves_to.first?.species.name
                        let evoDetails = chain.evolves_to.first?.evolution_details.first
                        return (from: previous?.species, to: next, details: evoDetails)
                    }

                    for evo in chain.evolves_to {
                        if let found = findEvolutionContext(in: evo, previous: (species: chain.species.name, details: chain.evolution_details)) {
                            return found
                        }
                    }

                    return nil
                }

                if let context = findEvolutionContext(in: evolution.chain, previous: nil) {
                    self.evolvesFrom = context.from?.capitalized
                    self.evolvesTo = context.to?.capitalized
                    self.evolutionLevel = context.to ?? "N/A"

                    if let evoDetail = context.details {
                        let trigger = evoDetail.trigger.name
                        if trigger == "level-up", let level = evoDetail.min_level {
                            self.evolutionMethod = "Level up at level \(level)"
                        } else if trigger == "use-item", let item = evoDetail.item?.name {
                            self.evolutionMethod = "Use item: \(item.capitalized)"
                        } else {
                            self.evolutionMethod = trigger.capitalized
                        }
                    } else {
                        self.evolutionMethod = "Unknown"
                    }
                } else {
                    self.evolvesFrom = nil
                    self.evolvesTo = nil
                    self.evolutionLevel = "N/A"
                    self.evolutionMethod = "Unknown"
                }
                self.errorMessage = nil
            } catch {
                self.errorMessage = "Pokémon not found or evolution data missing."
                self.pokemon = nil
                self.hp = nil
                self.attack = nil
                self.evolvesFrom = nil
                self.evolvesTo = nil
                self.evolutionLevel = "N/A"
                self.evolutionMethod = ""
            }
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Fuzzy Name Matching and Utility

struct PokemonList: Decodable {
    let results: [PokemonName]
}

struct PokemonName: Decodable {
    let name: String
}

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
