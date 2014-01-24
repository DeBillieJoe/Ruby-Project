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
    def make_move()
      possible_moves = valid_moves
      index = Random.rand(possible_moves.length)
      tiles_to_flip(possible_moves[index]).each { |move| board[*move] = tile }
    end
  end

  class Game

    attr_accessor :board, :player_one, :player_two
    
    def initialize(width, height)
      @board = Board.new
      @player_one = Human.new @board, BLACK_CELL
      @player_two = Computer.new @board, WHITE_CELL
    end
  end
end

class Console_GUI
  POSITION = "| %s ".freeze
  ROW = "----".freeze
  CELLS = {1 => "@".freeze, 2 => "O", 0 => " "}

  attr_accessor :boardGUI, :game, :tiles

  def initialize(width = 8, height = 8)
    @game = Reversi::Game.new width, height
    @boardGUI = ""
    @tiles = []
    @game.board.positions.each { |position| @tiles << CELLS[game.board[*position]] }
  end

  def put
    tile
    puts boardGUI % @tiles
  end

  def tile
    @tiles = []
    @game.board.positions.each { |position| @tiles << CELLS[game.board[*position]] }
  end

  def boardGUI
    @boardGUI = "  " + 1.upto(8).map(&:to_s).join("   ") + "\n" + (ROW*8 + "-\n" + POSITION*8 + "|\n")*8 + ROW*8 + "-\n"
  end
end


game = Console_GUI.new
game.put
puts "\n"
game.game.player_one.make_move [5, 4]
game.put

puts "\n"
game.game.player_two.make_move
game.put