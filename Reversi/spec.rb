# rspec spec.rb --require ./reversi.rb --colour --format documentation
describe "Board" do
  let(:board) { make_board }

  it "has 64 positions" do
    board.cells.length.should eq 64
  end

  it "has 2 black and 2 white tiles" do
    board.cells.count { |key, value| value == 1 }.should eq 2
    board.cells.count { |key, value| value == 2 }.should eq 2
  end

  it "can set cells" do
    board[1, 1] = 2
    board[1, 1].should eq 2
  end
end

describe "Player" do
  let(:board) { make_board }
  let(:player_one) { make_player board, 1}

  it "valid moves are correct" do
    player_one.valid_moves.should =~ [
                                      [3, 2], [5, 4],
                                      [2, 3], [4, 5]
                                     ]
  end

  it "[8, 8] and [4, 3] are not valid moves" do
    player_one.is_valid_move?([8, 8]).should be_false
    player_one.is_valid_move?([4, 3]).should be_false
  end

  it "[3, 2] and [4, 5] are valid moves" do
    player_one.is_valid_move?([3, 2]).should be_true
    player_one.is_valid_move?([4, 5]).should be_true
  end

  it "right cells to flip" do
    player_one.tiles_to_flip([3, 2]).should =~ [[3, 2], [3, 3]]
  end

  it "beginning score is 2" do
    player_one.score.should be 2
  end
end

describe "Human" do
  let(:board) { make_board }
  let(:player_one) { make_human board, 1}
  let(:player_two) { make_human board, 2}

  it "after move scores are 4 and 1" do
    player_one.make_move([3, 2])
    player_one.score.should be 4
    player_two.score.should be 1
  end

  it "after one move each, scores are equal" do
    player_one.make_move([3, 2])
    player_two.make_move([2, 2])
    player_one.score.should be 3
    player_two.score.should be 3
  end
end

describe "Computer" do
  let(:board) { make_board }
  let(:player_one) { make_human board, 1}
  let(:player_two) { make_computer board, 2}

  it "has 3 levels of difficulty" do
    player_two.respond_to?(:easy).should be_true
    player_two.respond_to?(:medium).should be_true
    player_two.respond_to?(:hard).should be_true
  end

  it "makes an easy move" do
    player_two.make_move(:easy).should be_true
  end

  it "makes a medium move" do
    setup_medium_move board
    player_two.make_move(:medium).should =~ [[4, 3], [4, 2], [4, 1], [4, 0]]
  end

  it "makes a hard move" do
    setup_hard_move board
    player_two.make_move(:hard).should =~ [[3, 0], [3, 1], [3, 2], [3, 3]]
  end
end



def make_board(args=nil)
  Reversi::Board.new(*args)
end

def make_player(board, tile)
  Reversi::Player.new(board, tile)
end

def make_human(board, tile)
  Reversi::Human.new(board, tile)
end

def make_computer(board, tile)
  Reversi::Computer.new(board, tile)
end

def setup_medium_move(board)
  board[3, 3] = 1
  board[4, 1] = 1
  board[4, 2] = 1
end

def setup_hard_move(board)
  board[3, 1] = 1
  board[3, 2] = 1
  board[3, 3] = 1
  board[3, 4] = 2
  board[4, 1] = 1
  board[4, 2] = 1
  board[4, 3] = 2
  board[4, 4] = 1
end