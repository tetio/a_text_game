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

  
  test "checking moves" do

    hall = %Place{name: "hall", money: 0}
    street = %Place{name: "street", money: 0}
    closet = %Place{name: "closet", money: 100, preposition: "in"}
    kitchen = %Place{name: "kitchen", money: 0}
    drug_store = %Place{name: "drug store", money: 0}



    transitions = %{ hall => [
        %Transition{destination: street, requiered: []},
        %Transition{destination: kitchen, requiered: []},
        %Transition{destination: closet, requiered: []}
      ]
    }

    game = %Game{current_place: hall, score: 0}

    possible_moves = valid_moves(game, transitions)
    b =  go_to("st", game, transitions)
    visible_places = what_do_you_see(game, transitions)

    assert "street" in Enum.map(possible_moves, &(&1.name))
    assert "drug store" not in Enum.map(possible_moves, &(&1.name))
    assert "You see a closet. "  in Enum.map(visible_places, &(&1))
    assert go_to("st", game, transitions) == street
  end
end