module Reversi
  WIDTH = 8
  HEIGHT = 8
  EMPTY_CELL = 0
  BLACK_CELL = 1
  WHITE_CELL = 2
  DIRECTIONS = [[0, 1], [1,1], [1, 0], [1, -1],
              [0, -1], [-1, -1], [-1, 0], [-1, 1]]
  OTHER_PLAYER = {BLACK_CELL => WHITE_CELL, WHITE_CELL => BLACK_CELL}


  class Board
    attr_accessor :cells

    def initialize(width = WIDTH, height = HEIGHT)
      @cells = {}
      0.upto(height-1) do |y|
        0.upto(width-1) do |x|
          cells[[x, y]] = EMPTY_CELL
        end
      end

      start_configuration
    end

    def start_configuration
      @cells[[(WIDTH/2)-1, (HEIGHT/2)-1]] = WHITE_CELL
      @cells[[(WIDTH/2)-1, (HEIGHT/2)]] = BLACK_CELL
      @cells[[(WIDTH/2), (HEIGHT/2)-1]] = BLACK_CELL
      @cells[[(WIDTH/2), (HEIGHT/2)]] = WHITE_CELL
    end

    def [](x, y)
      @cells[[x,y]]
    end

    def []=(x, y, value)
      @cells[[x, y]] = value
    end

    def is_move_on_board?(x, y)
      @cells.has_key? [x, y]
    end

    def empty?(x, y)
      @cells[[x, y]] == EMPTY_CELL
    end

    def positions
      @cells.keys
    end

    def values
      @cells.values
    end
  end

  class Player < Struct.new(:board, :tile)
    def is_valid_move?(cell)
      tiles_to_flip = []

      if board.is_move_on_board?(*cell) and board.empty? *cell
        board[*cell] = tile

        DIRECTIONS.each do |direction|
          x, y = *cell
          x, y = x + direction[0], y + direction[1]

          while board.is_move_on_board? x, y and board[x, y] == OTHER_PLAYER[tile]
            x, y = x + direction[0], y + direction[1]

            next unless board.is_move_on_board? x, y

            if board[x, y] == tile
              while [x, y] != cell
                x, y = x - direction[0], y - direction[1]
                tiles_to_flip << [x, y]
              end
            end
          end
        end

        board[*cell] = EMPTY_CELL
      end

      tiles_to_flip.length > 0 ? tiles_to_flip : false
    end

    def tiles_to_flip(cell)
      is_valid_move? cell
    end

    def valid_moves
      board.positions.select { |position| is_valid_move? position }
    end

    def score
      board.positions.count { |cell| board[*cell] == tile }
    end

  end

  class Human < Player
    def make_move(cell)
      tiles_to_flip(cell).each { |move| board[*move] = tile } if valid_moves.include? cell
    end
  end

  class Computer < Player
    def make_move(cell=nil)
      possible_moves = valid_moves
      index = Random.rand(possible_moves.length)
      tiles_to_flip(possible_moves[index]).each { |move| board[*move] = tile }
    end
  end
end

class Game
  attr_accessor :board, :player_one, :player_two, :gui

  def initialize(width = 8, height = 8)
    @board = Reversi::Board.new
    @player_one = Reversi::Human.new @board, Reversi::BLACK_CELL
    @player_two = Reversi::Human.new @board, Reversi::WHITE_CELL
    @gui = Console_GUI.new
    @turn = Reversi::BLACK_CELL
  end

  def run_game
    player, other_player = nil, nil

    while true
      gui.tiles board.cells.values
      puts gui
      gui.score player_one.score, player_two.score

      player, other_player = player_one.tile == @turn ? [player_one, player_two] : [player_two, player_one]

      break if player.valid_moves.empty?

      gui.turn player.tile
      player.is_a?(Reversi::Human) ? player_move(player) : computer_move(player)

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

  def computer_move(computer)
    gui.tiles computer.board.values
    computer.make_move
  end
end

class Console_GUI
  POSITION = "| %s ".freeze
  ROW = "----".freeze
  EDGE = "  " + ROW*8 + "-\n".freeze
  ROW_NUMBER = "%d ".freeze
  CELLS = {1 => "B".freeze, 2 => "W".freeze, 0 => " ".freeze}
  TURN = {1 => "\nPlayer one's turn\n".freeze, 2 => "\nPlayer two's turn\n".freeze}

  attr_accessor :boardGUI, :tiles

  def initialize
    @boardGUI = ""
    @tiles = []
  end

  def score(player_one, player_two)
    puts "\nPlayer 1: %s   Player 2: %s\n" % [player_one, player_two]
  end

  def to_s
    "\n" + boardGUI % @tiles + "\n"
  end

  def invalid_move
    puts "\n\n-------------\nInvalid move!\n-------------\n\n"
  end

  def tiles(values)
    @tiles = []
    values.each { |value| @tiles << CELLS[value] }
  end

  def boardGUI
    @boardGUI = "    " + 1.upto(8).map(&:to_s).join("   ") + "\n"
    (1..8).each do |i|
      @boardGUI += EDGE + ROW_NUMBER % i.to_s + POSITION*8 + "|\n"
    end
    @boardGUI += EDGE
  end

  def player_input
    puts "\nMake your move! It should be two digits separated by space\n"
    input = nil
    until input
      input = /^[1-8] [1-8](\n)$/.match gets
      invalid_move if input.nil?
    end
    input.to_s.split(' ').map(&:to_i)
  end

  def turn(tile)
    puts TURN[tile]
  end
end


game = Game.new
game.run_game
