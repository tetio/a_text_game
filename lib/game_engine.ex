defmodule GameEngine do
  def what_do_you_see(game, transitions) do
    Enum.map(transitions[game.current_place], fn transition ->
      "You see #{transition.destination.article} #{transition.destination.name}. "
    end)
  end

  def valid_moves(game, transitions) do
    Enum.map(transitions[game.current_place], & &1.destination)
  end

  def go_to(user_input, game, transitions) do
    destination =
      Enum.filter(valid_moves(game, transitions), &String.starts_with?(&1.name, user_input))

    case destination do
      [head | _] ->
        if head.name in game.visited do
          %Game{current_place: head, score: game.score, visited: game.visited}
        else
          %Game{
            current_place: head,
            score: game.score + head.money,
            visited: [head.name | game.visited]
          }
        end
      _ ->
        game
    end
  end

  def is_game_over?(user_input, game, end_game) do
    user_input == "quit" or (game.current_place == end_game and game.score > 1000)
  end
end
