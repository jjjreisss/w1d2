require 'set'

class Card
  attr_reader :value, :face_up
  def initialize(value)
    @face_up = false
    @value = value
  end

  def hide
    @face_up = false
  end

  def reveal
    @face_up = true
  end

  def to_s
    @face_up ? value : '*'
  end

  def ==(card)
    return false unless card.is_a?(Card)
    @value == card.value
  end
end

class Board
  attr_reader :grid

  def initialize(size = [4,5])
    @grid = Array.new(size.first) { Array.new(size.last) }
    raise ArgumentError if !card_count.even?
  end

  def populate
    place_pair until @grid.flatten.none?(&:nil?)
  end

  def card_count
    @grid.size * @grid.first.size / 2
  end

  def place_pair
    ('a'..'z').first(card_count).each do |letter|
      2.times { place_card(Card.new(letter)) }
    end
  end

  def place_card(card)
    coordinates = [rand(@grid.size), rand(@grid[0].size)]
    until @grid[coordinates[0]][coordinates[1]].nil?
      coordinates = [rand(@grid.size), rand(@grid[0].size)]
    end
    @grid[coordinates[0]][coordinates[1]] = card
  end

  def render
    puts @grid.map { |row| row.join(' ') }.join("\n")
  end

  def won?
    @grid.flatten.all? { |card| card.face_up }
  end

  def reveal(pos)
    @grid[pos.first][pos.last].reveal
  end

  def [](pos)
    @grid[pos[0]][pos[1]]
  end
end

class Game

  def initialize(board = Board.new, player = ComputerPlayer.new)
    @player = player
    @board = board
    @previous_guess = nil
  end

  def play
    @board.populate
    @board.render
    until @board.won?
      play_turn
    end
  end

  def play_turn
    pos = @player.get_input(@board)
    make_guess(pos)
  end

  def make_guess(pos)
    @board.reveal(pos)
    card1 = @board[pos]
    if @previous_guess
      display
      card2 = @board[@previous_guess]
      flip_back(card1, card2) if card1 != card2
      @previous_guess = nil
      @board.render
    else
      system("clear")
      @board.render
      @previous_guess = pos
    end
  end

  def flip_back(card1, card2)
    card1.hide
    card2.hide
  end

  def display
    system("clear")
    @board.render
    sleep(1)
    system("clear")
  end
end

class HumanPlayer
  def get_input(board)
    puts "What is your guess?"
    pos = gets.chomp.split("").map { |el| el.to_i }
  end
end

class ComputerPlayer
  def initialize
    @known_positions = {}
    @matches = Set.new
    @previous_guess = nil
  end


  def get_input(board)
    values = @known_positions.values

    if values.count(@previous_value)>1
      guess = [nil,nil]
      @known_positions.delete(@previous_guess)
      @matches.add(@previous_guess)
      @known_positions.each_pair do |position, value|
        guess = position if value == @previous_value
      end
      @known_positions.delete(guess)
      guess
    else
      guess = [rand(board.grid.size), rand(board.grid[0].size)]
      value = board[guess].value
      @known_positions[guess] = value
      @previous_guess = guess
      @previous_value = value
      guess
    end

  end

end
