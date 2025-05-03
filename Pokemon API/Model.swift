//
//  Model.swift
//  Pokemon API
//
//  Created by frank on 5/3/25.
//

import Foundation

//this is where the pokemon data will populate
struct Pokemon: Decodable {
    let name: String
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
// this is the sprite picked
struct Sprites: Decodable {
    let front_default: String
}
//this is where the evolutionchain call happens, and shows what and where the pokemons evolutions are
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

//this section was built specifically for Eevee with help. The evolution tree was very challenging to understand how to traverse in the documentation. I chalk that up entirely to my lack of experience reading APIs and thinking with a dev/coding/programming mindset
struct EvolutionOption: Identifiable {
    let id = UUID()
    let name: String
    let method: String
    let spriteURL: String?
}

// I had to let the llm show me how to implement this. The advanced nature of the search and how the string differential works was a little beyond me.

struct PokemonList: Decodable {
    let results: [PokemonName]
}

struct PokemonName: Decodable {
    let name: String
}
