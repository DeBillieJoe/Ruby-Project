module Reversi
  WIDTH = 8
  HEIGHT = 8
  EMPTY_CELL = 0
  BLACK_CELL = 1
  WHITE_CELL = 2
  DIRECTIONS = [[0, 1], [1,1], [1, 0], [1, -1],
              [0, -1], [-1, -1], [-1, 0], [-1, 1]].freeze
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

    def empty_cell?(x, y)
      @cells[[x, y]] == EMPTY_CELL
    end

    def full?
      @cells.all? { |key, value| not empty_cell? *key}
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

      if board.is_move_on_board?(*cell) and board.empty_cell? *cell
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
    def make_move(difficulty)
      move = send difficulty
      tiles_to_flip(move).each { |cell| board[*cell] = tile }
    end

    def easy
      index = Random.rand(valid_moves.length)
      valid_moves[index]
    end

    def medium
      possible_moves = valid_moves.shuffle
      possible_moves[index possible_moves]
    end

    def hard
      possible_moves = good_moves
      if possible_moves.empty?
        possible_moves = bad_moves
      end

      possible_moves[index possible_moves]
    end

    def index(possible_moves)
      possible_moves.map { |cell| tiles_to_flip(cell).size }.each_with_index.max[1]
    end

    def bad_moves
      possible_moves = valid_moves

      risk_moves = possible_moves.select { |move| Positions::RISK.include? move}
      really_bad_moves = possible_moves.select { |move| Positions::BAD.include? move}

      not_so_bad_moves = possible_moves - risk_moves - really_bad_moves

      if not_so_bad_moves.any?
        not_so_bad_moves
      elsif risk_moves.any?
        risk_moves
      else
        really_bad_moves
      end
    end

    def good_moves
      possible_moves = valid_moves

      corner_moves = possible_moves.select { |move| Positions::CORNERS.include? move}
      edge_moves = possible_moves.select { |move| Positions::EDGES.include? move}

      if corner_moves.any?
        corner_moves
      else
        edge_moves
      end
    end
  end

  module Positions
    CORNERS = [[0, 0], [WIDTH-1, 0], [0, HEIGHT-1], [WIDTH-1, HEIGHT-1]].freeze

    vertical_edges = [0, WIDTH-1].product 2.upto(HEIGHT-3).to_a
    horizontal_edges = 2.upto(WIDTH-3).to_a.product [0, HEIGHT-1]

    EDGES = (vertical_edges + horizontal_edges).freeze

    vertical_risk_positions = [1, WIDTH-2].product 2.upto(HEIGHT-3).to_a
    horizontal_risk_positions = 2.upto(WIDTH-3).to_a.product [1, HEIGHT-1]

    RISK = (vertical_risk_positions + horizontal_risk_positions).freeze

    BAD = [[1, 0], [1, 1], [0, 1], [WIDTH-2, 0], [WIDTH-1, 1],
               [WIDTH-2, 1], [0, HEIGHT-2], [HEIGHT-1, 1], [HEIGHT-2, 1],
               [WIDTH-2, HEIGHT-1], [WIDTH-2, HEIGHT-2], [WIDTH-1, HEIGHT-2]].freeze
  end
end
