require 'debugger'

class Piece
  attr_accessor :pos, :color
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
    if moves.include?(new_pos)
      @board[@pos] = nil
      @pos = new_pos
      @board[@pos] = self
    end
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

  def deltas
    self.class::DELTAS
  end

  def display_char
    self.class::DISPLAY_CHAR
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
    debugger
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
    moves
  end
end

class King < SteppingPiece
  # MOVE_DELTAS =
  DISPLAY_CHAR = "K "
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
  DISPLAY_CHAR = "N "
end

class Pawn < SteppingPiece

  MOVE_DELTAS = {
    :white => [[-1, 0]],
    :black => [[1, 0]]
  }
  DISPLAY_CHAR = "P "

  def initialize(board, color, pos)
    super(board, color, pos)
    @moves_num = 0
  end

  def diagonal_captures
    diagonal_moves = []
    row_delta = self.class::MOVE_DELTAS[0][0]
    diagonal_moves << [row_delta, 1] if capture_possible?([row_delta, 1])
    diagonal_moves << [row_delta, -1] if capture_possible?([row_delta, -1])
    diagonal_moves
  end



  def moves
    moves = []
    possible_moves = self.class::MOVE_DELTAS + diagonal_captures
    possible_moves += [[2,0], [-2,0]] if @turn_num == 0
    possible_moves.each do |delta|
      new_row = @pos[0] + delta[0]
      new_col = @pos[1] + delta[1]
      move = [new_row, new_col]
      if valid?(move) || capture_possible?(move)
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
  DISPLAY_CHAR = "Q "
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
  DISPLAY_CHAR = "B "
  MOVE_DELTAS = [  [-1, 1],
                   [1, 1],
                   [1, -1],
                   [-1, -1] ]

end

class Rook < SlidingPiece
  DISPLAY_CHAR = "R "
  MOVE_DELTAS = [  [1, 0],
                   [0, 1],
                   [-1, 0],
                   [0, -1] ]

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

  def to_s
    output = " "
    @board.each do |row|
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




end