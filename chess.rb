require 'debugger'

class Piece
  attr_accessor :pos, :color

  def initialize(board, color, pos)
    @board = board
    @color = color
    @pos = pos
  end


  def moves
    #returns array of places a piece can move to
    raise NotYetImplemented
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
    if move.any? { |coord| coord < 0 || coord > 7 }
      return false
    end
    @board[move].color != color
  end

end

class SlidingPiece < Piece
  attr_reader :move_dirs

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_dirs = []
  end

  def moves
    moves = []
    @move_dirs.each do |dir|
      moves += moves_in_one_dir(dir)
    end
    moves
  end

  private
  def moves_in_one_dir(dir)
    moves = []
    new_row = @pos[0] + dir[0]
    new_col = @pos[1] + dir[1]
    loop do
      move = [new_row, new_col]
      if valid?(move)
        moves << move
      elsif capture_possible?(move)
        moves << move
        return moves
      else
        return moves
      end
      new_row = new_row + dir[0]
      new_col = new_col + dir[1]
    end
  end

end

class Queen < SlidingPiece

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_dirs = [[1, 0], [-1, 0], [1, 1], [1, -1], [-1, -1], [-1, 1], [0, 1], [0, -1]]
  end

end


class Board

  def initialize
    @board = Array.new(8) { Array.new(8) }
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, piece)
    row, col = pos
    @board[row][col] = piece
  end


  def move!(piece, new_pos)
    self[new_pos] = piece
    piece.pos = new_pos
  end

end