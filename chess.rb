# encoding: utf-8
require 'debugger'

class Piece
  attr_accessor :pos, :color, :moves_num
  attr_reader :display_char

  def initialize(board, color, pos)
    @board = board
    @color = color
    @pos = pos
  end


  def moves
    #returns array of places a piece can move to
    raise NotYetImplemented
  end

  def move(new_pos)
    if valid_moves(moves).include?(new_pos)
      @board[@pos] = nil
      @pos = new_pos
      @board[@pos] = self
    end
  end

  def valid_moves(moves)
     moves.select { |move| move_into_check?(self, move) != true }
  end

  def valid?(new_pos)
    #desired space is on the board and not occupied
    if new_pos.any? { |coord| coord < 0 || coord > 7 }
      return false
    end
    unless @board[new_pos].nil?
      return false
    end
    true
  end

  def capture_possible?(move)
    #check that the space is on the board
    if move.any? { |coord| coord < 0 || coord > 7 } || @board[move].nil?
      return false
    end
    @board[move].color != color
  end

  def deltas
    self.class::DELTAS
  end

  def display_char
    self.class::DISPLAY_CHAR[self.color]
  end

  def move_into_check?(copy_of_board, end_pos)
    board_copy = @board.deep_dup
    piece_copy = self.class.new(board_copy, self.color, self.pos)
    piece_copy.moves_num = self.moves_num
    debugger
    board_copy[piece_copy.pos] = piece_copy
    board_copy.move!(piece_copy, end_pos)
    board_copy.in_check?(piece_copy.color)
    false
  end

end

class SlidingPiece < Piece
  attr_reader :board

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_dirs = []
  end

  def moves
    moves = []
    self.class::MOVE_DELTAS.each do |dir|
      moves += moves_in_one_dir(dir)
    end
    moves
  end

  private
  def moves_in_one_dir(dir)
    valid_moves = []
    current = apply_delta(@pos, dir)
    until blocked?(current)
      valid_moves << current
      current = apply_delta(current, dir)
    end
    unless valid?(current) && @board[current].nil?
      valid_moves << current if capture_possible?(current)
    end
    valid_moves
  end

  def apply_delta(pos, delta)
    new_row = pos[0] + delta[0]
    new_col = pos[1] + delta[1]
    [new_row, new_col]
  end

  def blocked?(pos)
    return true unless valid?(pos)
    unless @board[pos].nil?
      return true if capture_possible?(pos)
    end
    false
  end


end

class SteppingPiece < Piece

  def initialize(board, color, pos)
    super(board, color, pos)
  end

  def moves
    moves = []
    self.class::MOVE_DELTAS.each do |delta|
      new_row = @pos[0] + delta[0]
      new_col = @pos[1] + delta[1]
      move = [new_row, new_col]
      if valid?(move) || capture_possible?(move)
        moves << move
      end
    end
    valid_moves(moves)
  end
end

class King < SteppingPiece
  # MOVE_DELTAS =
  DISPLAY_CHAR = {
    :white => "\u2654 ",
    :black => "\u265A "
  }
  MOVE_DELTAS = [ [1, 0],
                  [-1, 0],
                  [1, 1],
                  [1, -1],
                  [-1, -1],
                  [-1, 1],
                  [0, 1],
                  [0, -1] ]

end

class Knight < SteppingPiece
  MOVE_DELTAS = [ [2, 1],
                   [2, -1],
                   [-2, 1],
                   [-2, -1],
                   [-1, 2],
                   [-1, -2],
                   [1, 2],
                   [1, -2] ]
  DISPLAY_CHAR = {
    :white => "\u2658 ",
    :black => "\u265E "
  }
end

class Pawn < SteppingPiece

  MOVE_DELTAS = {
    :white => [[-1, 0]],
    :black => [[1, 0]]
  }
  DISPLAY_CHAR = {
    :white => "\u2659 ",
    :black => "\u265F "
  }

  def initialize(board, color, pos)
    super(board, color, pos)
    @moves_num = 0
  end

  def diagonal_captures
    diagonal_moves = []
    row_delta = MOVE_DELTAS[@color][0][0]
    unless @board[[row_delta, 1]].nil?
      diagonal_moves << [row_delta, 1] if capture_possible?([row_delta, 1])
    end
    unless @board[[row_delta, -1]]
      diagonal_moves << [row_delta, -1] if capture_possible?([row_delta, -1])
    end
    diagonal_moves
  end

  def move(new_pos)
    if moves.include?(new_pos)
      @board[@pos] = nil
      @pos = new_pos
      @board[@pos] = self
      @moves_num += 1
    end
  end

  def moves
    moves = []
    possible_moves = deltas + diagonal_captures
    possible_moves += [[2,0], [-2,0]] if @moves_num == 0
    possible_moves.each do |delta|
      new_row = @pos[0] + delta[0]
      new_col = @pos[1] + delta[1]
      move = [new_row, new_col]
      if valid?(move) || diagonal_captures.include?(move)
        moves << move
      end
    end
    moves
  end

  def deltas
    MOVE_DELTAS[color]
  end
end




class Queen < SlidingPiece
  DISPLAY_CHAR = {
    :white => "\u2655 ",
    :black => "\u265B "
  }
  MOVE_DELTAS = [  [1, 0],
                   [-1, 0],
                   [1, 1],
                   [1, -1],
                   [-1, -1],
                   [-1, 1],
                   [0, 1],
                   [0, -1] ]

end

class Bishop < SlidingPiece
  DISPLAY_CHAR = {
    :white => "\u2657 ",
    :black => "\u265D "
  }
  MOVE_DELTAS = [  [-1, 1],
                   [1, 1],
                   [1, -1],
                   [-1, -1] ]

end

class Rook < SlidingPiece
  DISPLAY_CHAR = {
    :white => "\u2656 ",
    :black => "\u265C "
  }
  MOVE_DELTAS = [  [1, 0],
                   [0, 1],
                   [-1, 0],
                   [0, -1] ]

end


class Board

  def initialize(board = nil)
    @board = board || Array.new(8) { Array.new(8) }
    if board.nil?
      setup_board
    end
  end

  def setup_board
    pieces = [Rook, Knight, Bishop, King, Queen, Bishop, Knight, Rook]
    pieces.each_with_index do |piece, col|
      self[[0, col]] = piece.new(self, :black, [0, col])
      self[[7, col]] = piece.new(self, :white, [7, col])
    end
    @board[1].each_index do |col|
      self[[1, col]] = Pawn.new(self, :black, [1, col])
      self[[6, col]] = Pawn.new(self, :white, [6, col])
    end
  end

  def deep_dup
    arr = Array.new(8) { Array.new(8) }
    board_copy = Board.new(arr)
    @board.each do |row|
      new_row = []
      row.each do |space|
        if !space.nil?
          board_copy[space.pos] = space.class
                        .new(board_copy, space.color, space.pos)
        end
      end
    end
    board_copy
  end

  def locate_king(color)
    @board.each do |row|
      row.each do |space|
        next if space.nil?
        next if space.color != color
        return space.pos if space.is_a?(King)
      end
    end
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, piece)
    row, col = pos
    @board[row][col] = piece
  end

  def move(start_pos, end_pos)
    raise "Position off board" if out_of_bounds?(start_pos) ||
                                  out_of_bounds?(end_pos)
    piece = self[start_pos]
    raise "No piece present at start position" if piece.nil?
    raise "Not a valid move for this piece" unless piece.moves.include?(end_pos)
    raise "Move would put you in check" unless piece.valid_moves(end_pos)
    move!(piece, end_pos)
  end

  def move!(piece, new_pos)
    self[piece.pos] = nil
    self[new_pos] = piece
    piece.pos = new_pos
  end

  def out_of_bounds?(pos)
    return true if pos.any? { |coord| coord > 7 || coord < 0 }
    false
  end

  def to_s
    output = "   0 1 2 3 4 5 6 7\n "
    @board.each_with_index do |row, row_index|
      output += "#{row_index} "
      row.each do |space|
        if space.nil?
          output += "* "
        else
          output += space.display_char
        end
      end
      output += "\n "
    end
    output
  end

  def in_check?(color)
    @board.each do |row|
      row.each do |space|
        next if space.nil?
        if space.color != color
          return true if space.moves.any? { |move| move == locate_king(color) }
        end
      end
    end
    false
  end

  def checkmate?(color)
    @board.each do |row|
      row.each do |space|
        next if space.nil?
        next if space.color != color
        return false if space.valid_moves(space.moves).empty?
      end
    end
    true
  end

end

class Game
  attr_reader :board
  COLORS = { :white => "White",
             :black => "Black"
           }

  def initialize(player1, player2)
    @player1 = player1
    @player2 = player2
    @board = Board.new
  end

  def play
    turn = :white
    puts @board
    puts "White goes first."
    begin
      start_pos, end_pos = get_move(turn)
      raise "Not your piece!" if @board[start_pos].color != turn
      @board.move(start_pos, end_pos)
    rescue
      retry
    end
  end

  def get_move(turn)
    puts "#{COLORS[turn]} pick a move e.x. 03,05 :"
    start_pos, end_pos = gets.chomp.split(',')
    start_pos = start_pos.split('').map(&:to_i)
    end_pos = end_pos.split('').map(&:to_i)
    [start_pos, end_pos]
  end


end

if __FILE__ == $PROGRAM_NAME
  g = Game.new('a', 'b')
  g.play
end