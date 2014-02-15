class ConsoleUi
  POSITION = "| %s ".freeze
  ROW = "----".freeze
  EDGE = "  " + ROW*8 + "-\n".freeze
  ROW_NUMBER = "%d ".freeze
  CELLS = {1 => "B".freeze, 2 => "W".freeze, 0 => " ".freeze}
  TURN = {1 => "\nPlayer one's turn\n".freeze, 2 => "\nPlayer two's turn\n".freeze}
  DIFFICULTIES = ["easy", "medium", "hard"]

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
      input = /^[1-8] [1-8]$/.match gets.chomp
      invalid_move if input.nil?
    end
    input.to_s.split(' ').map(&:to_i)
  end

  def turn(tile)
    puts TURN[tile]
  end

  def difficulty
    puts "\nChoose computer's difficulty: easy, medium or hard\n"
    difficulty = nil
    until difficulty
      difficulty = gets.chomp
      difficulty = nil unless DIFFICULTIES.include?(difficulty)
    end
    difficulty
  end
end