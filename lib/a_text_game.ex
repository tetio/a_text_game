defmodule ATextGame do
  import Place
  import Transition
  import GameEngine

  def start() do
    ball = %GameItem{name: "ball"}
    comb = %GameItem{name: "comb"}
    soap = %GameItem{name: "soap"}

    hall = %Place{name: "hall", money: 0}
    street = %Place{name: "street", money: 0}
    closet = %Place{name: "closet", items: [ball], money: 100, preposition: "in"}
    kitchen = %Place{name: "kitchen", money: 10}
    drug_store = %Place{name: "drug store", items: [soap, comb], money: 0}
    bus_station = %Place{name: "bus station", money: 0}

    bus_to_downtown = %Place{name: "bus to downtown", money: -5}
    downtown = %Place{name: "downtown", money: 0}
    bus_to_home = %Place{name: "bus to home", money: -5}

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
      ],
      bus_station => [
        street,
        bus_to_downtown
      ],
      bus_to_downtown => [
        bus_station,
        downtown
      ]
    }

    end_game = bus_station
    main_loop(%Game{current_place: hall}, transitions, end_game, needed_items)
  end
end
