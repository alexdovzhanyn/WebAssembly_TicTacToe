defmodule WasmTtt do
  use Application
  use WaspVM.HostFunction
  require IEx

  def start(_type, _args) do
    Task.start(fn -> run_game() end)
  end

  def run_game do
    # Start a fresh VM instance
    {:ok, pid} = WaspVM.start()

    # Generate host functions based on the current module
    imports = WaspVM.HostFunction.create_imports(__MODULE__)

    # Load a WebAssembly module into the VM from a .wasm file
    WaspVM.load_file(pid, "priv/wasm/tic_tac_toe.wasm", imports)

    {:ok, gas, winning_player} = WaspVM.execute(pid, "play")

    log_winner(winning_player)

    IO.puts "This game of Tic-Tac-Toe burned #{gas} gas."
  end

  defhost :get_move_for_player, [player] do
    p = if player == 0, do: "X", else: "O"

    {tile, _} =
      "\nPlayer #{p}, which tile? > "
      |> IO.gets()
      |> Integer.parse()

    tile
  end

  defhost :draw_board do
    board = WaspVM.HostFunction.API.get_memory(ctx, "game_mem", 0, 9)

    IO.puts ""

    rows = for <<a::8, b::8, c::8 <- board>>, do: {<<a>>, <<b>>, <<c>>}

    rows
    |> Enum.with_index()
    |> Enum.each(fn {{a, b, c}, idx} ->
      if idx == 1, do: IO.puts "---+---+---"

      IO.puts " #{charfor(a)} | #{charfor(b)} | #{charfor(c)}"

      if idx == 1, do: IO.puts "---+---+---"
    end)
  end

  defhost :invalid_move do
    IO.puts "Invalid Move! Try again."
  end

  defhost :log, [a] do
    IO.puts("Log: #{a}")
  end

  defp log_winner(player) do
    p = if player == 0, do: "X", else: "O"

    IO.puts "Tic Tac Toe, 3 in a row! Player #{p} has won the game."
  end

  defp charfor(<<0>>), do: " "
  defp charfor(i), do: i
end
