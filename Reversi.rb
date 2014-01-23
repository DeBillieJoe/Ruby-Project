module Reversi
  WIDTH = 8
  HEIGHT = 8
  EMPTY_CELL = 0
  BLACK_CELL = 1
  WHITE_CELL = 2
  DIRECTIONS = [[0, 1], [1,1], [1, 0], [1, -1],
              [0, -1], [-1, -1], [-1, 0], [-1, 1]]

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
  end

  class Player < Struct.new(:tile, :score = 2)

  end
end
