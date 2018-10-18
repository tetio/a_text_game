defmodule GameEngine do
  def what_do_you_see(game, transitions) do
    case transitions[game.current_place] do
     [_h | _]  ->
      Enum.map(transitions[game.current_place], fn place ->
        "You see #{place.article} #{place.name}. "
      end)

      
      _ ->
        "You see nothing..."
    end

  end

  def where_you_are(game) do
    "You are in #{game.current_place.article} #{game.current_place.name}. "
  end

  def has_all_needed_items(items, bag) do
    Enum.all?(items, &(&1 in bag))
  end

  def valid_moves(game, transitions, needed_items) do
    Enum.filter(transitions[game.current_place], fn destination ->
      if needed_items[destination] == nil or
           has_all_needed_items(needed_items[destination], game.bag) do
        destination
      end
    end)
  end

  def go_to(user_input, game, transitions, needed_items) do
    destinations =
      Enum.filter(
        valid_moves(game, transitions, needed_items),
        &String.starts_with?(&1.name, user_input)
      )

    case destinations do
      [destination | _] ->
        if destination.name in game.visited do
          %Game{current_place: destination, score: game.score, visited: game.visited}
        else
          %Game{
            current_place: destination,
            bag: destination.items ++ game.bag,
            score: game.score + destination.money,
            visited: [destination.name | game.visited]
          }
        end

      _ ->
        game
    end
  end

  def is_game_over?(game, end_game) do
    # and game.score > 1000)
    game.current_place == end_game
  end

  def user_whants_to_quit?(user_input) do
    user_input == "quit"
  end

  def you_have(game) do
    s = "Your score is #{game.score}"

    case game.bag do
      [_h | _] ->
        s <> " and you have " <> Enum.join(Enum.map(game.bag, & &1.article <> " " <> &1.name), ", ") <> "."

      [] ->
        s
    end
  end

  def display_game_data(game, transitions) do
    IO.puts(where_you_are(game) <> you_have(game))
    IO.puts(what_do_you_see(game, transitions))
  end

  def main_loop(game, transitions, end_game, needed_items) do
    display_game_data(game, transitions)

    if is_game_over?(game, end_game) do
      IO.puts("*************************************")
      IO.puts("***         Well done!            ***")
      IO.puts("*************************************")
    else
      user_command = IO.gets("game:>") |> String.trim()

      if user_whants_to_quit?(user_command) do
        IO.puts("*************************************")
        IO.puts("***          Good bye!            ***")
        IO.puts("*************************************")
      else
        main_loop(
          go_to(user_command, game, transitions, needed_items),
          transitions,
          end_game,
          needed_items
        )
      end
    end
  end
end
