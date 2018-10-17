defmodule SomeDataTest do
  use ExUnit.Case
  doctest SomeData
  import User
  import Cat

  test "set name ok" do
    aUser = %User{name: "Sergi"}

    assert aUser.name == "Sergi"
  end

  test "set name KO" do
    user = %User{name: "Pere"}
    assert user.name != "Sergi"
  end

  test "a recorded cat" do
    #siv = %Cat{name: "Siv", breed: "Skogskatt", age: 13}
    siv = cat(name: "Siv", breed: "Skogskatt", age: 13)
    an_age = cat(siv, :age)
    assert an_age == 13
  end
end
