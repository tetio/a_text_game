defmodule SomeData do
  require Record
  Record.defrecord :user, name: "john", age: 25

  @type user :: record(:user, name: String.t, age: integer)
  # expands to: "@type user :: {:user, String.t, integer}"
end
