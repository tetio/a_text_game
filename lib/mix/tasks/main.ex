defmodule Mix.Tasks.Main do
  use Mix.Task
  import ATextGame

  @shortdoc "Perform my task"

  def run(_) do
    ATextGame.start()
  end
end
