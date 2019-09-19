defmodule GameEngine do


  def is_in_bag?(game_items, item) do
    game_items[item].state == "bag"
  end


  def items_in_bag(game_items) do
    Enum.filter(game_items, fn {_k, v} -> v.state == "bag" end)
  end


  def what_do_you_see(game, transitions) do
    here = game.places[game.current_place]
    look_at_place(game, transitions) <>
      look_in_containers(Enum.map(here.containers, &game.containers[&1]))
  end


  def look_at_place(game, transitions) do
    case transitions[game.current_place] do
      [_h | _] ->
        Enum.map(transitions[game.current_place], fn destination ->
          place = game.places[destination]
          "You see #{place.article} #{place.name}."
        end)
        |> Enum.join(" ")
      _ ->
        "You see nothing..."
    end
  end


  def look_in_containers(containers) do
    case containers do
      [_h | _] ->
        " You also see " <>
          (Enum.map(containers, &(&1.article <> " " <> &1.name)) |> Enum.join(", "))
      _ ->
        ""
    end
  end


  def mark_as_seen(game, items) do
    updated_items =
      Enum.filter(items, &(game.items[&1].state == "unseen"))
      |> Enum.map(fn item -> {item, struct(game.items[item], state: "seen")} end)
      |> Map.new()
    updated_game_items = Map.merge(game.items, updated_items)
    %Game{game | items: updated_game_items}
  end


  def get_subject(user_input) do
    [_verb | subjects] = String.split(user_input, " ")
    Enum.join(subjects, " ")
  end


  def what_is_inside(user_input, transitions, game) do
    subject = get_subject(user_input)
    container_name = subject
    here = game.places[game.current_place]
    case Enum.filter(here.containers, &String.contains?(&1, container_name)) do
      [a | _] ->
        s =
          Enum.filter(game.containers[a].items, &(game.items[&1].state != "bag"))
          |> Enum.map(&"#{game.items[&1].article} #{game.items[&1].name}")
          |> Enum.join(", ")
        items =
          case s do
            "" -> "nothing"
            _ -> s
          end
        IO.puts(
          IO.ANSI.cyan() <>
            "Inside the #{game.containers[a].name} you see #{items}." <> IO.ANSI.default_color()
        )
        mark_as_seen(game, game.containers[a].items)
      [] ->
        # now we are
        place = subject
        destinations =
          Enum.filter(
            transitions[game.current_place] ++ [game.current_place],
            &String.contains?(&1, place)
          )
        case destinations do
          [d | _] ->
            case String.contains?(d, game.current_place) do
              false -> IO.puts("You can not see what is in there, you are a little far away.")
              true -> IO.puts(look_at_place(game, transitions))
            end
          _ ->
            IO.puts("There is nothing like that.")
        end
        game
    end
  end


  def where_you_are(game) do
    "You are in #{game.places[game.current_place].article} #{game.places[game.current_place].name}. "
  end


  def has_all_needed_items?(items, game_items) do
    Enum.all?(items, &is_in_bag?(game_items, &1))
  end


  def valid_moves(game, transitions, needed_items) do
    Enum.filter(transitions[game.current_place], fn destination ->
      if needed_items[destination] == nil or
           has_all_needed_items?(needed_items[destination], game.items) do
        destination
      end
    end)
  end


  def goto_command(user_input, game, transitions, needed_items) do
    place = get_subject(user_input)
    destinations =
      Enum.filter(
        valid_moves(game, transitions, needed_items),
        &String.starts_with?(&1, place)
      )
    case destinations do
      [destination | _] ->
        if destination in game.visited do
          struct(game, current_place: destination)
        else
          struct(game,
            score: game.score + game.places[destination].money,
            visited: [destination | game.visited],
            current_place: destination
          )
        end
      _ ->
        game
    end
  end


  def use_command(user_input, game) do
    subject = get_subject(user_input)
    object =
      Enum.map(items_in_bag(game.items), fn {k, _v} -> k end)
      |> Enum.filter(&String.starts_with?(&1, subject))
    case object do
      ["ball" | _] -> IO.puts("You play with the ball")
      _ -> IO.puts("I don't know what do you want to use.")
    end
    game
  end


  def look_command(user_input, transitions, game) do
    what_is_inside(user_input, transitions, game)
  end


  def pickup_command(user_input, game) do
    item_to_pickup = get_subject(user_input)
    # 1- Check if object is in any container in the current_room
    containers = game.places[game.current_place].containers
    items =
      Enum.flat_map(containers, &game.containers[&1].items)
      |> Enum.filter(&(String.starts_with?(&1, item_to_pickup) and game.items[&1].state == "seen"))
    case items do
      [i | _] ->
        IO.puts("you have picked #{game.items[i].article} #{game.items[i].name}")
        item_updated = struct(game.items[i], state: "bag")
        struct(game, items: Map.merge(game.items, %{i => item_updated}))
      _ ->
        IO.puts(IO.ANSI.red() <> "Item not found" <> IO.ANSI.default_color())
        game
    end
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
    my_items = items_in_bag(game.items)
    case my_items do
      [_h | _] ->
        s <>
          " and you have " <>
          Enum.join(Enum.map(my_items, fn {_k, v} -> v.article <> " " <> v.name end), ", ") <> "."

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
        "key: #{k} name: #{v.name}, state: #{v.state}, value: #{v.value}, article: #{v.article}"
      end)
      |> Enum.join("\n")
    IO.puts(IO.ANSI.yellow() <> s <> IO.ANSI.default_color())
  end


  def main_loop(game, transitions, end_game, needed_items) do
    display_game_data(game, transitions)
    if is_game_over?(game, end_game) do
      message =
        IO.ANSI.cyan() <>
          """
          *************************************
          ***         Well done!            ***
          *************************************
          """ <> IO.ANSI.default_color()
      IO.puts(message)
    else
      prompt = IO.ANSI.green() <> "game:>" <> IO.ANSI.default_color()
      user_command = IO.gets(prompt) |> String.trim()
      if user_wants_to_quit?(user_command) do
        message =
          IO.ANSI.cyan() <>
            """
            *************************************
            ***          Good bye!            ***
            *************************************
            """ <> IO.ANSI.default_color()

        IO.puts(message)
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
              look_command(user_command, transitions, game),
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
