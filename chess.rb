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

class SteppingPiece < Piece
  attr_reader :move_deltas

  def initialize(board, color, pos)
    super(board, color, pos)
  end

  def moves
    moves = []
    @move_deltas.each do |delta|
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

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_deltas = [ [1, 0],
                   [-1, 0],
                   [1, 1],
                   [1, -1],
                   [-1, -1],
                   [-1, 1],
                   [0, 1],
                   [0, -1] ]
  end

end

class Knight < SteppingPiece

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_deltas = [ [2, 1],
                   [2, -1],
                   [-2, 1],
                   [-2, -1],
                   [-1, 2],
                   [-1, -2],
                   [1, 2],
                   [1, -2] ]
  end
end

class Pawn < SteppingPiece

  def initialize(board, color, pos)
    super(board, color, pos)
    color == 'white' ? @move_deltas = [ [-1, 0] ] : @move_deltas = [ [1, 0] ]

    @turn_num = 0
  end

  def moves
    moves = []
    moves += [[2,0], [-2,0]] if @turn_num == 0
    @move_deltas.each do |delta|
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




class Queen < SlidingPiece

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_dirs = [ [1, 0],
                   [-1, 0],
                   [1, 1],
                   [1, -1],
                   [-1, -1],
                   [-1, 1],
                   [0, 1],
                   [0, -1] ]
    @display_char = "Q "
  end

end

class Bishop < SlidingPiece

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_dirs = [ [-1, 1],
                   [1, 1],
                   [1, -1],
                   [-1, -1] ]
    @display_char = "B "
  end
end

class Rook < SlidingPiece

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_dirs = [ [1, 0],
                   [0, 1],
                   [-1, 0],
                   [0, -1] ]
    @display_char = "R "
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