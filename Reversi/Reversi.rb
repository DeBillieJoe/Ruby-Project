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

    def initialize()
      @cells = {}
      0.upto(HEIGHT-1) do |y|
        0.upto(WIDTH-1) do |x|
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

  class Player < Struct.new(:board, :tile, :score)
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

    def valid_moves
      board.positions.select { |position| is_valid_move? position }
    end
  end
end