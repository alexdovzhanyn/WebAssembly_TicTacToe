defmodule WasmTttTest do
  use ExUnit.Case
  doctest WasmTtt

  test "greets the world" do
    assert WasmTtt.hello() == :world
  end
end
