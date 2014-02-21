require './reversi.rb'
require './console_ui.rb'


class Game
  include Reversi

  attr_accessor :board, :player_one, :player_two, :gui

  def initialize(width = 8, height = 8)
    @board = Board.new
    @player_one = Human.new @board, BLACK_CELL
    @player_two = Computer.new @board, WHITE_CELL
    @gui = ConsoleUi.new
    @turn = BLACK_CELL
  end

  def run_game
    player, other_player = nil, nil
    difficulty = gui.difficulty if player_two.is_a? Reversi::Computer

    while true
      gui.tiles board.cells.values
      puts gui
      gui.score player_one.score, player_two.score

      players = [player_one, player_two]
      player, other_player = player_one.tile == @turn ? players : players.reverse

      break if player.valid_moves.empty?

      gui.turn player.tile
      if player.is_a? Reversi::Human
        player_move player
      else
        computer_move player, difficulty
      end

      if not other_player.valid_moves.empty?
        @turn = other_player.tile
      end
    end

    end_game
    sleep(1)
  end

  def end_game
    winner = "Winner! Winner! Chicken dinner!"
    tie = "It's a tie!"

    puts winner if player_one.score != player_two.score
    puts tie if player_one.score == player_two.score
  end

  def player_move(player)
    move = nil

    until move
      move = gui.player_input

      move.map! { |position| position - 1 }
      if not move.nil? and not player.is_valid_move? move
        gui.invalid_move
        move = nil
      end
    end

    gui.tiles player.board.cells.values
    player.make_move move
  end

  def computer_move(computer, difficulty)
    gui.tiles computer.board.values
    computer.make_move difficulty
  end
end

game = Game.new
game.run_game
