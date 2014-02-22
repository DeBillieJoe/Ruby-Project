require 'green_shoes'
require './reversi.rb'
include Reversi

WINDOWWIDTH = 640
WINDOWHEIGHT = 480
WIDTH = 8
HEIGHT = 8
SPACE = 50

X_OFFSET = (WINDOWWIDTH-(WIDTH*SPACE))/2
Y_OFFSET = (WINDOWHEIGHT-(HEIGHT*SPACE))/2

BLACK_TILE = Reversi::BLACK_CELL
WHITE_TILE = Reversi::WHITE_CELL

def draw_board
  fill green
  rect X_OFFSET, Y_OFFSET, SPACE*WIDTH, SPACE*HEIGHT

  (1..WIDTH).each do |x|
    line X_OFFSET + x*SPACE, Y_OFFSET, X_OFFSET + x*SPACE, Y_OFFSET + HEIGHT*SPACE
    line X_OFFSET, Y_OFFSET + x*SPACE, X_OFFSET + WIDTH*SPACE, x*SPACE + Y_OFFSET
  end
end

def get_center_pixels(x, y)
  [(X_OFFSET + x*SPACE) + 5, (Y_OFFSET + y*SPACE) + 5]
end

def draw_tiles(board)
  (0..HEIGHT.pred).each do |y|
    (0..WIDTH.pred).each do |x|
      if board[x, y] != 0
        fill TILECOLORS[board[x, y]]
        oval *get_center_pixels(x, y), (SPACE/2) - 5
      end
    end
  end
end

def clicked_square_coordinates(left, top)
  (0..HEIGHT.pred).each do |y|
    (0..WIDTH.pred).each do |x|
      horizontal = top.between?(x*SPACE + X_OFFSET, (x+1) * SPACE + X_OFFSET)
      vertical = left.between?(y*SPACE + Y_OFFSET, (y+1) * SPACE + Y_OFFSET)
      return [x, y] if horizontal and vertical
    end
  end
  nil
end

def is_click_in_square?(left, top, x, y)
  horizontal = left.beetween? x*SPACE + X_OFFSET, (x+1) * SPACE + X_OFFSET
  vertical = top.between? y*SPACE + Y_OFFSET, (y+1) * SPACE + Y_OFFSET
  horizontal and vertical
end

def clicked(board)
  click do |button, top, left|
    coords = clicked_square_coordinates left, top
    board[*coords] = 1
  end
end

def player_move(coordinates)
  player.make_move(coordinates) ? true : false
end

def score_and_turn(players, turn)
  turn_message = {BLACK_TILE => "black", WHITE_TILE => "white"}
  @score.replace "Player one #{players[0].score}, Player two #{players[1].score}"
  @turn.replace "Turn: #{turn_message[turn]}"
end

def check_for_winner?(board, players)
  winner_message = "Winner! Winner! Chicken dinner!"
  tie_message = "It's a tie"
  if board.full? or players.all? { |player| player.valid_moves.empty? }
    @winner.replace "#{winner_message}" if players[0].score != players[1].score
    @winner.replace = "#{tie_message}" if  players[0].score == players[1].score
  end
end

def start_setup
  board = Board.new
  players = [Human.new(board, BLACK_TILE), Human.new(board, WHITE_TILE)]
  [board, players]
end

def rage_quit
  keypress do |k|
    fill red
    rect 0, 0, WINDOWWIDTH, WINDOWHEIGHT
    para "!!!RAGE QUIT!!!", align: 'center'
  end
end

Shoes.app width: WINDOWWIDTH, height: WINDOWHEIGHT, title: "Reversi" do
  TILECOLORS = {BLACK_TILE => black, WHITE_TILE => white}
  TURNS = {BLACK_TILE => WHITE_TILE, WHITE_TILE => BLACK_TILE}


  @score = para top: WINDOWHEIGHT - Y_OFFSET, left: WINDOWWIDTH - X_OFFSET*2.5
  @turn = para top:  WINDOWHEIGHT - Y_OFFSET, left: X_OFFSET
  @winner = para top: Y_OFFSET / 2, left: WINDOWWIDTH / 3

  background red
  rage_quit
  board, players = start_setup

  draw_board
  draw_tiles board

  turn = BLACK_TILE
  score_and_turn players, turn

  click do |button, top, left|
    if button == 1
      coords = clicked_square_coordinates left, top

      player_on_turn = players.select { |player| player.tile == turn }.first
      other_player = players.select { |player| player_on_turn != player }.first

      move = player_on_turn.make_move coords

      #section for computer move
      # if player_on_turn.is_a? Human
      #   move = player_on_turn.make_move coords
      # else
      #   move = player_on_turn.make_move "hard"
      # end

      if move
        turn = TURNS[turn] unless other_player.valid_moves.empty?
        score_and_turn players, turn
        draw_board
        draw_tiles board
      end

      check_for_winner? board, players
    end
  end
end