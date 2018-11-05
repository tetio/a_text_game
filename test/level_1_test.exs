defmodule Level1Test do
  use ExUnit.Case
  import Place
  import Transition
  import GameEngine
  import ATextGame

  test "empty room" do
    place = %Place{}
    assert place.name == "room" and place.items == []
  end

  test "into the hall" do
    place = %Place{name: "hall", money: 100}
    assert place.name == "hall" and place.money == 100
  end

  test "checking moves using new transitions" do
    ball = %GameItem{name: "ball"}
    comb = %GameItem{name: "comb"}
    soap = %GameItem{name: "soap"}
    cup = %GameItem{name: "cup"}
    hut_key = %GameItem{name: "hut key"}
    salt = %GameItem{name: "salt", article: "some"}
    cap = %GameItem{name: "cap"}
    hammer = %GameItem{name: "hammer"}
    nails = %GameItem{name: "nails", article: "some"}

    game_items = %{
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

    end_game = hall

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

    game = %Game{current_place: hall, score: 0, items: game_items}

    possible_moves = valid_moves(game, transitions, needed_items)
    game = goto_command("goto st", game, transitions, needed_items)
    game = goto_command("goto h", game, transitions, needed_items)
    assert is_game_over?(game, end_game) == true
    game = goto_command("goto k", game, transitions, needed_items)
    assert is_game_over?(game, end_game) == false
    game = goto_command("goto h", game, transitions, needed_items)
    l = what_do_you_see(game, transitions)
    assert String.contains?(l, "You see a closet.")
    game = goto_command("goto k", game, transitions, needed_items)
    game = goto_command("goto wwww", game, transitions, needed_items)
    game = goto_command("goto h", game, transitions, needed_items)

    game = look_command("look closet", game)

    game = look_command("look closet", game)

    visible_places = what_do_you_see(game, transitions)

    assert "street" in Enum.map(possible_moves, & &1.name)
    assert "drug store" not in Enum.map(possible_moves, & &1.name)
    assert String.contains?(visible_places, "You see a closet.")
    assert goto_command("goto street", game, transitions, needed_items).current_place == street
    game = goto_command("goto st", game, transitions, needed_items)
    assert goto_command("goto drug", game, transitions, needed_items).current_place == street
    game = %Game{current_place: street, bag: [ball], items: game_items}
    assert goto_command("goto drug", game, transitions, needed_items).current_place == drug_store

    use_command("use ball", game)
  end

  # test "a game " do
  #   ATextGame.start()
  # end
end
