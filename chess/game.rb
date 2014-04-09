# encoding: utf-8
require 'colorize'

class Game
  attr_reader :board

  COLORS = { :white => :black,
             :black => :white
           }

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @board = Board.new
    player1.board = @board
    player2.board = @board
    @turns = {
      :white => @player1,
      :black => @player2
    }
  end

  def play
    turn = :white
    puts "White goes first."
    e = nil
    until @board.checkmate?(turn) do
      begin
        system 'clear'
        if e
          puts e.message
          e = nil
        end
        puts "Check!" if @board.in_check?(turn)
        puts @board
        start_pos, end_pos = @turns[turn].play_turn(turn)
        @board.move(start_pos, end_pos)
      rescue RuntimeError => e
        retry
      end
      turn = COLORS[turn]
    end
    puts @board
    puts "#{COLORS[turn]} wins!"
  end


end

class HumanPlayer
  attr_accessor :board
  ALPHA_TO_COORD = {
    'a' => 0,
    'b' => 1,
    'c' => 2,
    'd' => 3,
    'e' => 4,
    'f' => 5,
    'g' => 6,
    'h' => 7
  }

  X_TO_ROW = {
    -1 => 7,
    -2 => 6,
    -3 => 5,
    -4 => 4,
    -5 => 3,
    -6 => 2,
    -7 => 1,
    -8 => 0
  }

  def play_turn(color)
    puts "#{color} pick a move e.x. f2,f4 :"
    start_pos, end_pos = gets.chomp.split(',')
    start_pos = translate_coordinate(start_pos)
    raise "No piece present at start position" if @board[start_pos].nil?
    raise "Not your piece!" if @board[start_pos].color != color
    end_pos = translate_coordinate(end_pos)
    [start_pos, end_pos]
  end

  private
  def translate_coordinate(chess_pos)
    col, row = chess_pos.split('')
    [X_TO_ROW[row.to_i * -1], ALPHA_TO_COORD[col]]
  end


end