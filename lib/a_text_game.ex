defmodule ATextGame do
  import GameEngine

  def start() do
    cup = %Item{name: "cup"}
    hut_key = %Item{name: "hut key"}
    salt = %Item{name: "salt", article: "some"}
    cap = %Item{name: "cap"}
    hammer = %Item{name: "hammer"}
    nails = %Item{name: "nails", article: "some"}

    cupboard = %Container{name: "cupboard", items: [cup, salt, hut_key]}
    closet = %Container{name: "closet", items: [cap]}

    hall = %Place{name: "hall", money: 0, containers: ["closet"]}
    street = %Place{name: "street", money: 0}
    kitchen = %Place{name: "kitchen", money: 10, containers: ["cupboard"]}
    hut = %Place{name: "hut", items: ["hammer", "nails"], money: 0}
    bus_station = %Place{name: "bus station", money: 0}
    downtown_bus_station = %Place{name: "downtown bus station", money: 0}

    bus_to_downtown = %Place{name: "bus to downtown", money: -5}
    bus_to_home = %Place{name: "bus to home", money: -5}
    downtown = %Place{name: "downtown", money: 0}

    needed_items = %{
      "hut" => ["hut_key"]
    }

    places = %{
      "hall" => hall,
      "street" => street,
      "kitchen" => kitchen,
      "hut" => hut,
      "bus_station" => bus_station,
      "bus_to_downtown" => bus_to_downtown,
      "downtown_bus_station" => downtown_bus_station,
      "bus_to_home" => bus_to_home,
      "downtown" => downtown
    }

    containers = %{
      "cupboard" => cupboard,
      "closet" => closet
    }

    items = %{
      "cap" => cap,
      "hut_key" => hut_key,
      "salt" => salt,
      "cup" => cup,
      "hammer" => hammer,
      "nails" => nails
    }

    transitions = %{
      "hall" => [
        "street",
        "kitchen"
      ],
      "kitchen" => [
        "hall"
      ],
      "street" => [
        "hall",
        "hut",
        "bus_station"
      ],
      "bus_station" => [
        "street",
        "bus_to_downtown"
      ],
      "bus_to_downtown" => [
        "downtown_bus_station",
        "bus_station"
      ],
      "downtown_bus_station" => [
        "downtown",
        "bus_to_home"
      ]
    }

    end_game = "bus_station"






    main_loop(%Game{current_place: "hall", places: places, items: items, containers: containers}, transitions, end_game, needed_items)
  end
end
