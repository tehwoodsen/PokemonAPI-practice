//
//  ContentView.swift
//  Pokemon API
//
//  Created by Erik Woods on 4/28/25.
//

import SwiftUI


struct ContentView: View {
    @State private var pokemonName = ""
    @State private var pokemon: Pokemon?
    @State private var errorMessage: String?
    @State private var correctedName: String?
    @State private var allPokemonNames: [String] = []
    @State private var evolutionOptions: [EvolutionOption] = []
    @State private var previousOptions: [EvolutionOption] = []
    @State private var showScrollDownIndicator = true
    @State private var showScrollUpButton = false
    
    @ObservedObject var viewModel = ViewModel()
    
//this is the section that defines the search field
    var body: some View {
        NavigationView {
            ScrollViewReader { proxy in
                ScrollView(.vertical, showsIndicators: true) {
                    VStack {
                        Color.clear
                            .frame(height: 1)
                            .background(GeometryReader { geo in
                                Color.clear.preference(key: ScrollOffsetKey.self, value: geo.frame(in: .named("scroll")).maxY)
                            })

                        TextField("Enter Pokémon name", text: $pokemonName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()

                        Button("Search") {
                            fetchPokemon(named: pokemonName.lowercased())
                        }
//the start of the fuzzy logic reference
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

                                VStack {
                                    ForEach(pokemon.stats, id: \.stat.name) { stat in
                                        Text("\(stat.stat.name.capitalized): \(stat.base_stat)")
                                    }
                                }
                                .padding(.top, 4)
                            }
                            .padding()

                            if !previousOptions.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Previous Evolutions:")
                                        .font(.headline)
                                    ForEach(previousOptions) { option in
                                        Button {
                                            pokemonName = option.name.lowercased()
                                            fetchPokemon(named: option.name.lowercased())
                                        } label: {
                                            HStack {
                                                if let url = option.spriteURL, let spriteURL = URL(string: url) {
                                                    AsyncImage(url: spriteURL) { image in
                                                        image.resizable()
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    .frame(width: 40, height: 40)
                                                }
                                                Text(option.name)
                                                Spacer()
                                                if !option.method.isEmpty {
                                                    Text(option.method)
                                                        .italic()
                                                }
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding()
                            }

                            if !evolutionOptions.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Possible Evolutions:")
                                        .font(.headline)
                                    ForEach(evolutionOptions) { option in
                                        Button {
                                            pokemonName = option.name.lowercased()
                                            fetchPokemon(named: option.name.lowercased())
                                        } label: {
                                            HStack {
                                                if let url = option.spriteURL, let spriteURL = URL(string: url) {
                                                    AsyncImage(url: spriteURL) { image in
                                                        image.resizable()
                                                    } placeholder: {
                                                        ProgressView()
                                                    }
                                                    .frame(width: 40, height: 40)
                                                }
                                                Text(option.name)
                                                Spacer()
                                                Text(option.method)
                                                    .italic()
                                            }
                                        }
                                        .buttonStyle(PlainButtonStyle())
                                    }
                                }
                                .padding()
                            }
                        } else if let errorMessage = errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }

                        // Removed Spacer() to allow scrolling
                    }
                    .id(0)
                }
                .onPreferenceChange(ScrollOffsetKey.self) { value in
                    showScrollDownIndicator = value > (UIScreen.main.bounds.height - 50)
                    showScrollUpButton = value < (UIScreen.main.bounds.height - 50)
                }
                .overlay(alignment: .bottom) {
                    if showScrollDownIndicator {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.compact.down")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .opacity(0.6)
                            Spacer()
                        }
                    } else if showScrollUpButton {
                        HStack {
                            Spacer()
                            Image(systemName: "chevron.compact.down")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                                .opacity(0.6)
                            Spacer()
                        }
                    }
                }
                .coordinateSpace(name: "scroll")
            }
            .navigationTitle("Pokémon Search")
        }
    }

    func fetchPokemon(named name: String) {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            errorMessage = "Please enter a Pokémon name."
            return
        }
        Task {
            let inputName = trimmed
            if allPokemonNames.isEmpty {
                allPokemonNames = await viewModel.fetchAllPokemonNames()
            }

            var searchName = inputName.lowercased()
            correctedName = nil
            if !allPokemonNames.contains(searchName) {
                if let corrected = viewModel.findClosestPokemonName(for: searchName, in: allPokemonNames) {
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

                // Fetch evolution data
                let (speciesData, _) = try await URLSession.shared.data(from: URL(string: decodedPokemon.species.url)!)
                let species = try JSONDecoder().decode(Species.self, from: speciesData)

                let (evolutionData, _) = try await URLSession.shared.data(from: URL(string: species.evolution_chain.url)!)
                let evolution = try JSONDecoder().decode(EvolutionDetail.self, from: evolutionData)

                func findChainNode(in chain: Chain, for speciesName: String) -> Chain? {
                    if chain.species.name == speciesName {
                        return chain
                    }
                    for evo in chain.evolves_to {
                        if let node = findChainNode(in: evo, for: speciesName) {
                            return node
                        }
                    }
                    return nil
                }

                func findAncestors(in chain: Chain, target: String) -> [Chain]? {
                    if chain.species.name == target {
                        return []
                    }
                    for evo in chain.evolves_to {
                        if let path = findAncestors(in: evo, target: target) {
                            return [chain] + path
                        }
                    }
                    return nil
                }

                // Find the node for the current Pokémon in the evolution tree
                guard let node = findChainNode(in: evolution.chain, for: searchName) else {
                    self.evolutionOptions = []
                    self.previousOptions = []
                    return
                }
                // I had to ask the LLM to help build this, this helped implement the node and chains for the evolution.
                var options: [EvolutionOption] = []
                for child in node.evolves_to {
                    let evoName = child.species.name
                    // Determine method
                    let detail = child.evolution_details.first
                    var methodStr = "Unknown"
                    if let d = detail {
                        let trigger = d.trigger.name
                        if trigger == "level-up", let level = d.min_level {
                            methodStr = "Level up at level \(level)"
                        } else if trigger == "use-item", let item = d.item?.name {
                            methodStr = "Use item: \(item.capitalized)"
                        } else {
                            methodStr = trigger.capitalized
                        }
                    }
                    // Fetch sprite
                    let sprite = await viewModel.fetchPokemonSprite(for: evoName)
                    options.append(EvolutionOption(name: evoName.capitalized, method: methodStr, spriteURL: sprite))
                }
                self.evolutionOptions = options

                // Build previous options
                var prev: [EvolutionOption] = []
                if let ancestorChains = findAncestors(in: evolution.chain, target: searchName) {
                    for node in ancestorChains {
                        let name = node.species.name
                        let sprite = await viewModel.fetchPokemonSprite(for: name)
                        // determine method if desired, else use empty
                        let detail = node.evolution_details.first
                        var methodStr = ""
                        if let d = detail {
                            let trigger = d.trigger.name
                            if trigger == "level-up", let level = d.min_level {
                                methodStr = "Leveled at \(level)"
                            } else if trigger == "use-item", let item = d.item?.name {
                                methodStr = "Used \(item.capitalized)"
                            } else {
                                methodStr = trigger.capitalized
                            }
                        }
                        prev.append(EvolutionOption(name: name.capitalized, method: methodStr, spriteURL: sprite))
                    }
                }
                self.previousOptions = prev

                self.errorMessage = nil
            } catch {
                self.errorMessage = "Pokémon not found or evolution data missing."
                self.pokemon = nil
                self.evolutionOptions = []
                self.previousOptions = []
            }
        }
    }
}

#Preview {
    ContentView()
}

