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

end

class SlidingPiece < Piece
  attr_reader :move_dirs

  def initialize(board, color, pos)
    super(board, color, pos)
    @move_dirs = []

  def moves
    moves = []
    @move_dirs.each do |dir|

      while true
        new_row = @pos[0] + dir[0]
        new_col = @pos[1] + dir[1]
        move = [new_row, new_col]
        if valid?(move)
          moves << move
        elsif capture_possible?(move)
          moves << move
          break
        else
          break
        end
      end
    end
    moves
  end

end

class Queen < SlidingPiece

  def initialize(board, color, pos)
    super(board, color pos)
    @move_dirs = [[1, 0], [-1, 0], [1, 1], [1, -1], [-1, -1], [-1, 1], [0, 1], [0, -1]]
  end

  def moves
    moves = []
    @move_dirs.each do |dir|

      loop do
        new_row = @pos[0] + dir[0]
        new_col = @pos[1] + dir[1]
        move = [new_row, new_col]
        if valid?(move)
          moves << move
        elsif capture_possible?(move)
          moves << move
          break
        else
          break
        end
      end
    end
    moves
  end

  def valid?(new_pos)
    #desired space is on the board and not occupied
    unless new_pos.all? { |coord| coord.between?(0, 7) }
      return false
    end
    unless @board[pos].nil?
      return false
    end
    true
  end

  def capture_possible?(move)
    #check that the space is on the board
    unless move.all? { |coord| coord.between?(0, 7) }
      return false
    end
    @board[move].color != color
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

end