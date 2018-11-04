defmodule GameEngine do
  def what_do_you_see(game, transitions) do
    look_at_place(game, transitions) <> look_in_containers(game.current_place.containers)
  end

  def look_at_place(game, transitions) do
    case transitions[game.current_place] do
      [_h | _] ->
        Enum.map(transitions[game.current_place], fn place ->
          "You see #{place.article} #{place.name}."
        end)
        |> Enum.join(" ")

      _ ->
        "You see nothing..."
    end
  end

  def look_in_containers(containers) do
    if containers != [] do
      " You also see " <>
        (Enum.map(containers, &(&1.article <> " " <> &1.name)) |> Enum.join(", "))
    else
      ""
    end
  end

  def mark_as_seen(game, containerName, items) do
    updatedItems =
      Enum.map(items, fn item ->
        struct(item, seen: true)
      end)

    otherContainers = Enum.filter(game.current_place.containers, &(&1.name != containerName))
    containers = otherContainers ++ %Container{name: containerName, items: updatedItems}
    cp = struct(game.current_place, container: containers)
    struct(game, current_place: cp)
  end

  def what_is_inside(user_input, game) do
    [_verb | containerNameArray] = String.split(user_input, " ")
    [container | _] = containerNameArray

    case Enum.filter(game.current_place.containers, &String.contains?(&1.name, container)) do
      [a | _] ->
        s = Enum.map(a.items, &"#{&1.article} #{&1.name}") |> Enum.join(", ")
        IO.puts(IO.ANSI.red() <> "Inside the #{a.name} you see #{s}." <> IO.ANSI.default_color())
        mark_as_seen(game, container, a.items)

      [] ->
        IO.puts("There is nothing like that.")
        game
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

  def goto_command(user_input, game, transitions, needed_items) do
    [_verb | place] = String.split(user_input, " ")

    destinations =
      Enum.filter(
        valid_moves(game, transitions, needed_items),
        &String.starts_with?(&1.name, place)
      )

    case destinations do
      [destination | _] ->
        if destination.name in game.visited do
          %Game{
            current_place: destination,
            bag: game.bag,
            score: game.score,
            visited: game.visited
          }
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

  def use_command(user_input, game) do
    [_verb | subject] = String.split(user_input, " ")

    # TODO check if player has the object
    [object | _] = Enum.filter(game.bag, &String.starts_with?(&1.name, subject))

    case object.name do
      "ball" -> IO.puts("You play with the ball")
      _ -> IO.puts("I don't know what do you want to use.")
    end

    game
  end

  def look_command(user_input, game) do
    what_is_inside(user_input, game)
  end

  def pickup_command(user_input, game) do
    game
  end

  def is_game_over?(game, end_game) do
    # and game.score > 1000)xx
    game.current_place == end_game
  end

  def user_wants_to_quit?(user_input) do
    user_input == "quit"
  end

  def you_have(game) do
    s = "Your score is #{game.score}"

    case game.bag do
      [_h | _] ->
        s <>
          " and you have " <>
          Enum.join(Enum.map(game.bag, &(&1.article <> " " <> &1.name)), ", ") <> "."

      [] ->
        s
    end
  end

  def display_game_data(game, transitions) do
    IO.puts(where_you_are(game) <> you_have(game))
    IO.puts(what_do_you_see(game, transitions))
  end

  def dispatch(user_input) do
    cond do
      String.starts_with?(user_input, "goto") -> :goto
      String.starts_with?(user_input, "open") -> :open
      String.starts_with?(user_input, "use") -> :use
      String.starts_with?(user_input, "look") -> :look
      String.starts_with?(user_input, "pickup") -> :pickup
      true -> :unknown
    end
  end

  def main_loop(game, transitions, end_game, needed_items) do
    display_game_data(game, transitions)

    if is_game_over?(game, end_game) do
      IO.puts("*************************************")
      IO.puts("***         Well done!            ***")
      IO.puts("*************************************")
    else
      prompt = IO.ANSI.green() <> "game:>" <> IO.ANSI.default_color()
      user_command = IO.gets(prompt) |> String.trim()

      if user_wants_to_quit?(user_command) do
        IO.puts("*************************************")
        IO.puts("***          Good bye!            ***")
        IO.puts("*************************************")
      else
        case dispatch(user_command) do
          :goto ->
            main_loop(
              goto_command(user_command, game, transitions, needed_items),
              transitions,
              end_game,
              needed_items
            )

          :use ->
            main_loop(
              use_command(user_command, game),
              transitions,
              end_game,
              needed_items
            )

          :look ->
            main_loop(
              look_command(user_command, game),
              transitions,
              end_game,
              needed_items
            )

          _ ->
            main_loop(
              game,
              transitions,
              end_game,
              needed_items
            )
        end
      end
    end
  end
end
