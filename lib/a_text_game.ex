defmodule ATextGame do
  import Place
  import Transition
  import GameEngine

  def start() do


    cup = %GameItem{name: "cup"}
    hut_key = %GameItem{name: "hut key"}
    salt = %GameItem{name: "salt", article: "some"}
    cap = %GameItem{name: "cap"}
    hammer = %GameItem{name: "hammer"}
    nails = %GameItem{name: "nails", article: "some"}


    cupboard = %Container{name: "cupboard", items: [cup, salt, hut_key]}
    closet = %Container{name: "closet", items: [cap]}

    hall = %Place{name: "hall", money: 0, containers: [closet]}
    street = %Place{name: "street", money: 0}
    kitchen = %Place{name: "kitchen", money: 10, containers: [cupboard]}
    hut = %Place{name: "hut", items: [hammer, nails], money: 0}
    bus_station = %Place{name: "bus station", money: 0}
    downtown_bus_station = %Place{name: "downtown bus station", money: 0}

    bus_to_downtown = %Place{name: "bus to downtown", money: -5}
    bus_to_home = %Place{name: "bus to home", money: -5}
    downtown = %Place{name: "downtown", money: 0}

    needed_items = %{
      hut => [hut_key]
    }

    transitions = %{
      hall => [
        street,
        kitchen
      ],
      kitchen => [
        hall
      ],
      street => [
        hall,
        hut,
        bus_station
      ],
      bus_station => [
        street,
        bus_to_downtown
      ],
      bus_to_downtown => [
        downtown_bus_station,
        bus_station
      ],
      downtown_bus_station => [
        downtown,
        bus_to_home
      ]

    }

    end_game = bus_station
    main_loop(%Game{current_place: hall}, transitions, end_game, needed_items)
  end
end
