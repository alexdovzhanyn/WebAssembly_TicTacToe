(module
  (import "WasmTtt" "get_move_for_player" (func $get_move_for_player (param i32) (result i32)))
  (import "WasmTtt" "draw_board" (func $draw_board))
  (import "WasmTtt" "invalid_move" (func $invalid_move))
  (memory (export "game_mem") 1)
  (func (export "play") (result i32)
    block $end_game (result i32)
      loop $main
        i32.const 0
        call $turn
        if
          i32.const 0
          br $end_game
        end

        i32.const 1
        call $turn
        if
          i32.const 1
          br $end_game
        end

        br $main
      end

      i32.const 100
    end
  )

  (func $turn (param $player_num i32) (result i32) (local $cell i32)
    get_local $player_num
    call $get_move_for_player
    tee_local $cell

    ;; Check if cell is within range (less than 9)
    i32.const 9
    i32.lt_s

    ;; Check if cell is empty
    get_local $cell
    i32.load8_s
    i32.eqz

    ;; Binary "and" the above results. We want both values to be 1
    i32.and
    if (result i32)
      get_local $cell
      get_local $player_num
      call $player_char_from_number

      ;; Update the board
      i32.store8

      call $draw_board

      get_local $player_num
      call $check_winner
    else
      call $invalid_move
      get_local $player_num
      call $turn
    end
  )

  (func $check_winner (param $player_num i32) (result i32) (local $player_char i32)
    get_local $player_num
    call $player_char_from_number
    set_local $player_char

    ;; 8 Possible winning combinations:
    ;; [0, 1, 2], [3, 4, 5], [6, 7, 8], [0, 3, 6], [1, 4, 7], [2, 5, 8], [0, 4, 8], [2, 4, 6]
    ;; We could loop through each cell, but it would actually be more
    ;; performant to just check these combinations directly.

    ;; 0, 1, 2 ==============
    i32.const 2
    i32.const 1
    i32.const 0
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; 3, 4, 5 ==============
    i32.const 5
    i32.const 4
    i32.const 3
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; 6, 7, 8 ==============
    i32.const 8
    i32.const 7
    i32.const 6
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; 0, 3, 6 ==============
    i32.const 6
    i32.const 3
    i32.const 0
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; 1, 4, 7 ==============
    i32.const 7
    i32.const 4
    i32.const 1
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; 2, 5, 8 ==============
    i32.const 8
    i32.const 5
    i32.const 2
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; 0, 4, 8 ==============
    i32.const 8
    i32.const 4
    i32.const 0
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; 2, 4, 6 ==============
    i32.const 6
    i32.const 4
    i32.const 2
    get_local $player_char
    call $check_combo
    if
      i32.const 1
      return
    end
    ;; ======================

    ;; No combitions matched, no win. Return 0
    i32.const 0
  )

  (func $check_combo (param $player_char i32) (param $c1 i32) (param $c2 i32) (param $c3 i32) (result i32)
    get_local $c1
    get_local $player_char
    call $check_cell

    get_local $c2
    get_local $player_char
    call $check_cell

    i32.and

    get_local $c3
    get_local $player_char
    call $check_cell

    i32.and
  )

  (func $player_char_from_number (param $player_num i32) (result i32)
    get_local $player_num ;; 1 or 0
    if (result i32)
      i32.const 111 ;; o
    else
      i32.const 120 ;; x
    end
  )

  (func $check_cell (param $player_char i32) (param $cell i32) (result i32)
    get_local $cell
    i32.load8_s
    get_local $player_char
    i32.eq
  )
)
