require_relative '../pieces.rb'

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
    valid_move_list = []
    current = apply_delta(@pos, dir)
    until blocked?(current)
      valid_move_list << current
      current = apply_delta(current, dir)
    end
    unless valid?(current) && @board[current].nil?
      valid_move_list << current if capture_possible?(current)
    end
    valid_move_list
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