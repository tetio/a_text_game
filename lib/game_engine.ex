defmodule GameEngine do
  def what_do_you_see(game, transitions) do
    place = game.places[String.to_atom(prepare_name(game.current_place))]
    look_at_place(game, transitions) <> look_in_containers(place.containers)
  end

  def prepare_name(name) do
    String.replace(name, " ", "_")
  end

  def look_at_place(game, transitions) do
    case transitions[String.to_atom(prepare_name(game.current_place))] do
      [_h | _] ->
        Enum.map(transitions[String.to_atom(prepare_name(game.current_place))], fn place_name ->
          place = game.places[String.to_atom(prepare_name(place_name))]
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

  def mark_as_seen(game, items) do
    updated_items =
      Enum.map(items, fn item -> {item.name, struct(item, seen: true)} end) |> Map.new()

    updated_game_items = Map.merge(game.items, updated_items)
    struct(game, items: updated_game_items)
  end

  def get_subject(user_input) do
    [_verb | subjects] = String.split(user_input, " ")
    [subject | _] = subjects
    subject
  end

  def what_is_inside(user_input, game) do
    container_name = get_subject(user_input)
    place = game.places[String.to_atom(prepare_name(game.current_place))]
    case Enum.filter(place.containers, &String.contains?(&1.name, container_name)) do
      [a | _] ->
        s = Enum.map(a.items, &"#{&1.article} #{&1.name}") |> Enum.join(", ")
        IO.puts(IO.ANSI.red() <> "Inside the #{a.name} you see #{s}." <> IO.ANSI.default_color())

        mark_as_seen(game, a.items)

      # & {&1.name => &1}))

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
    Enum.filter(transitions[String.to_atom(prepare_name(game.current_place))], fn destination ->
      if needed_items[String.to_atom(prepare_name(destination))] == nil or
           has_all_needed_items(needed_items[String.to_atom(prepare_name(destination))], game.bag) do
        destination
      end
    end)
  end

  def goto_command(user_input, game, transitions, needed_items) do
    [_verb | place] = String.split(user_input, " ")

    destinations =
      Enum.filter(
        valid_moves(game, transitions, needed_items),
        &String.starts_with?(&1, place)
      )

    case destinations do
      [destination | _] ->
        if destination in game.visited do
          %Game{
            current_place: destination,
            bag: game.bag,
            score: game.score,
            visited: game.visited,
            items: game.items,
            places: game.places
          }
        else
          sss = game.places[String.to_atom(prepare_name(destination))]
          %Game{
            current_place: destination,
            bag: game.bag,
            score: game.score  + sss.money,
            visited: [destination | game.visited],
            items: game.items,
            places: game.places
          }
        end

      _ ->
        game
    end
  end

  def use_command(user_input, game) do
    [_verb | subject] = String.split(user_input, " ")

    # TODO check if player has the object
    [object | _] = Enum.filter(game.bag, &String.starts_with?(&1, subject))

    case object do
      "ball" -> IO.puts("You play with the ball")
      _ -> IO.puts("I don't know what do you want to use.")
    end

    game
  end

  def look_command(user_input, game) do
    what_is_inside(user_input, game)
  end

  def pickup_command(user_input, game) do
    object = get_subject(user_input)

    # TODO
    # 1- Check if object is in any container in the current_room
    # 2- Check if object is already seen
    # 3- remoive object from container and put it in the bag

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
      String.starts_with?(user_input, "debug") -> :debug
      true -> :unknown
    end
  end

  def debug(game) do
    s =
      Enum.map(game.items, fn {k, v} ->
        "key: #{k} name: #{v.name}, seen: #{v.seen}, value: #{v.value}, article: #{v.article}"
      end)
      |> Enum.join("\n")

    IO.puts(IO.ANSI.yellow() <> s <> IO.ANSI.default_color())
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

          :pickup ->
            main_loop(
              pickup_command(user_command, game),
              transitions,
              end_game,
              needed_items
            )

          :debug ->
            debug(game)

            main_loop(
              game,
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
