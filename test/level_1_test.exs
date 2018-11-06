defmodule Level1Test do
  use ExUnit.Case
  # import Place
  # import Transition
  import GameEngine
  # import ATextGame

  test "empty room" do
    place = %Place{}
    assert place.name == "room" and place.items == []
  end

  test "into the hall" do
    place = %Place{name: "hall", money: 100}
    assert place.name == "hall" and place.money == 100
  end

  test "checking moves using new transitions" do
    ball = %Item{name: "ball"}
    comb = %Item{name: "comb"}
    soap = %Item{name: "soap"}
    cup = %Item{name: "cup"}
    hut_key = %Item{name: "hut key"}
    salt = %Item{name: "salt", article: "some"}
    cap = %Item{name: "cap"}
    hammer = %Item{name: "hammer"}
    nails = %Item{name: "nails", article: "some"}

    items = %{
      "cap" => cap,
      "hut_key" => hut_key,
      "salt" => salt,
      "cup" => cup,
      "hammer" => hammer,
      "nails" => nails
    }



    cupboard = %Container{name: "copboard", items: [cup, salt, hut_key]}
    closet = %Container{name: "closet", items: [cap]}

    hall = %Place{name: "hall", money: 0, containers: [closet]}
    street = %Place{name: "street", money: 0}
    kitchen = %Place{name: "kitchen", money: 10, containers: [cupboard]}
    drug_store = %Place{name: "drug store", items: [soap, comb], money: 0}
    bus_station = %Place{name: "bus station", money: 0}

    end_game = "hall"

    needed_items = %{
      "drug_store" => ["ball"]
    }

    containers = %{
      "cupboard" => cupboard,
      "closet" => closet
    }

    places = %{
      "hall" => hall,
      "street" => street,
      "kitchen"=> kitchen,
      "drug_store" => drug_store,
      "us_station" => bus_station
    }

    transitions = %{
      "hall" => [
        "street",
        "kitchen"
      ],
      "closet" => [
        "hall"
      ],
      "kitchen" =>[
        "hall"
      ],
      "street" => [
        "hall",
        "drug_store",
        "bus_station"
      ]
    }

    game = %Game{current_place: "hall", score: 0, items: items, places: places}

    possible_moves = valid_moves(game, transitions, needed_items)
    assert "street" in Enum.map(possible_moves, & &1)
    assert "drug store" not in Enum.map(possible_moves, & &1)

    game = goto_command("goto st", game, transitions, needed_items)
    game = goto_command("goto h", game, transitions, needed_items)
    assert is_game_over?(game, end_game) == true
    game = goto_command("goto k", game, transitions, needed_items)
    assert is_game_over?(game, end_game) == false
    game = goto_command("goto h", game, transitions, needed_items)
    l = what_do_you_see(game, transitions)
    assert String.contains?(l, "You see a street.")
    game = goto_command("goto k", game, transitions, needed_items)
    game = goto_command("goto wwww", game, transitions, needed_items)
    game = goto_command("goto h", game, transitions, needed_items)

    game = look_command("look closet", game)

    game = look_command("look closet", game)

    visible_places = what_do_you_see(game, transitions)

    assert String.contains?(visible_places, "You also see a closet")
    assert goto_command("goto street", game, transitions, needed_items).current_place == "street"
    aGame = goto_command("goto st", game, transitions, needed_items)
    assert goto_command("goto drug", aGame, transitions, needed_items).current_place == "street"
    game = %Game{current_place: "street", bag: ["ball"], items: items, places: places}
    g = goto_command("goto drug", game, transitions, needed_items)
    assert g.current_place == "drug_store"

    use_command("use ball", game)
  end
end
