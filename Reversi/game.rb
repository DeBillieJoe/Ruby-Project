require './reversi.rb'
require './console_ui.rb'
include Reversi

class Game
  attr_accessor :board, :player_one, :player_two, :gui

  def initialize(width = 8, height = 8)
    @board = Reversi::Board.new
    @player_one = Reversi::Human.new @board, Reversi::BLACK_CELL
    @player_two = Reversi::Computer.new @board, Reversi::WHITE_CELL
    @gui = ConsoleUi.new
    @turn = Reversi::BLACK_CELL
  end

  def run_game
    player, other_player = nil, nil
    difficulty = gui.difficulty if player_two.is_a? Reversi::Computer

    while true
      gui.tiles board.cells.values
      puts gui
      gui.score player_one.score, player_two.score

      player, other_player = player_one.tile == @turn ? [player_one, player_two] : [player_two, player_one]

      break if player.valid_moves.empty?

      gui.turn player.tile
      player.is_a?(Reversi::Human) ? player_move(player) : computer_move(player, difficulty)

      if not other_player.valid_moves.empty?
        @turn = other_player.tile
      end
    end
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
