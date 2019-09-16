defmodule Mix.Tasks.Main do
  use Mix.Task

  @shortdoc "Perform my task"

  def run(_) do
    ATextGame.start()
  end
end
