defmodule Level1Test do
  use ExUnit.Case
  import Place
  import Transition
  import GameEngine

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

    hall = %Place{name: "hall", money: 0}
    street = %Place{name: "street", money: 0}
    closet = %Place{name: "closet", items: [ball], money: 100, preposition: "in"}
    kitchen = %Place{name: "kitchen", money: 10}
    drug_store = %Place{name: "drug store", items: [soap, comb], money: 0}
    bus_station = %Place{name: "bus station", money: 0}
    end_game = closet
    needed_items = %{
      drug_store => [ball]
    }
    transitions = %{ hall => [
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

    possible_moves = valid_moves(game, transitions, needed_items)
    game = goto_command("goto st", game, transitions, needed_items)
    game = goto_command("goto h", game, transitions, needed_items)
    game = goto_command("goto c", game, transitions, needed_items)
    assert is_game_over?(game, end_game) == true
    game = goto_command("goto h", game, transitions, needed_items)
    assert is_game_over?(game, end_game) == false
    game = goto_command("goto c", game, transitions, needed_items)
    game = goto_command("goto h", game, transitions, needed_items)
    game = goto_command("goto k", game, transitions, needed_items)
    game = goto_command("goto wwww", game, transitions, needed_items)
    game = goto_command("goto h", game, transitions, needed_items)
    visible_places = what_do_you_see(game, transitions)

    assert "street" in Enum.map(possible_moves, &(&1.name))
    assert "drug store" not in Enum.map(possible_moves, &(&1.name))
    assert "You see a closet. "  in Enum.map(visible_places, &(&1))
    assert goto_command("goto street", game, transitions, needed_items).current_place == street
    game = goto_command("goto st", game, transitions, needed_items)
    assert goto_command("goto drug", game, transitions, needed_items).current_place == drug_store
    game = %Game{current_place: street, bag: [ball]}
    assert goto_command("goto drug", game, transitions, needed_items).current_place == drug_store

    use_command("use ball", game)

  end
end
