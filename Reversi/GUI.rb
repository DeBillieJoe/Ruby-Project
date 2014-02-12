require 'green_shoes'
require './Reversi.rb'
include Reversi

WINDOWWIDTH = 640
WINDOWHEIGHT = 480
WIDTH = 8
HEIGHT = 8
SPACE = 50

X_OFFSET = (WINDOWWIDTH-(WIDTH*SPACE))/2
Y_OFFSET = (WINDOWHEIGHT-(HEIGHT*SPACE))/2

def draw_board
  fill green
  rect X_OFFSET, Y_OFFSET, SPACE*WIDTH, SPACE*HEIGHT

  (1..WIDTH).each do |x|
    line X_OFFSET + x*SPACE, Y_OFFSET, X_OFFSET + x*SPACE, Y_OFFSET + HEIGHT*SPACE
    line X_OFFSET, Y_OFFSET + x*SPACE, X_OFFSET + WIDTH*SPACE, x*SPACE + Y_OFFSET
  end
end

def get_center(x, y)
  [(X_OFFSET + x*SPACE)+5, (Y_OFFSET + y*SPACE)+5]
end

def draw_tiles(board)
  (0..HEIGHT.pred).each do |y|
    (0..WIDTH.pred).each do |x|
      if board[x, y] != 0
        fill TILECOLORS[board[x, y]]
        oval *get_center(x, y), (SPACE/2)-5
      end
    end
  end
end

Shoes.app width: WINDOWWIDTH, height: WINDOWHEIGHT, title: "Reversi" do
  TILECOLORS = {1 => :black, 2 => :white}

  background red
  board = Board.new
  draw_board
  draw_tiles board
end