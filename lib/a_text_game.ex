defmodule ATextGame do
  import Place
  import Transition
  import GameEngine

  def start(_type, _args) do
    ball = %GameItem{name: "ball"}
    comb = %GameItem{name: "comb"}
    soap = %GameItem{name: "soap"}

    hall = %Place{name: "hall", money: 0}
    street = %Place{name: "street", money: 0}
    closet = %Place{name: "closet", items: [ball], money: 100, preposition: "in"}
    kitchen = %Place{name: "kitchen", money: 10}
    drug_store = %Place{name: "drug store", items: [soap, comb], money: 0}
    bus_station = %Place{name: "bus station", money: 0}

    needed_items = %{
      drug_store => [ball]
    }

    transitions = %{
      hall => [
        street,
        kitchen,
        closet
      ],
      closet => [
        hall
      ],
      kitchen => [
        hall
      ],
      street => [
        hall,
        drug_store,
        bus_station
      ]
    }

    game = %Game{current_place: hall, score: 0}
    end_game = bus_station
    main_loop(%Game{current_place: hall}, transitions, end_game, needed_items)
  end
end
