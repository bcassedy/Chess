class Piece
  attr_accessor :pos, :moves_num
  attr_reader :color

  def initialize(board, color, pos)
    @board = board
    @color = color
    @pos = pos
  end

  def moves
    raise NotYetImplemented
  end

  def valid_moves(moves)
     moves.reject { |move| move_into_check?(move) }
  end

  def display_char
    self.class::DISPLAY_CHAR.colorize(:color => self.color)
  end

  private

  def valid?(new_pos)
    if new_pos.any? { |coord| coord < 0 || coord > 7 }
      return false
    end
    unless @board[new_pos].nil?
      return false
    end
    true
  end

  def capture_possible?(move)
    if move.any? { |coord| coord < 0 || coord > 7 } || @board[move].nil?
      return false
    end
    @board[move].color != @color
  end

  def deltas
    self.class::DELTAS
  end

  def move_into_check?(pos)
    board_copy = @board.deep_dup
    piece_copy = self.class.new(board_copy, self.color, self.pos)
    piece_copy.moves_num = self.moves_num
    board_copy[piece_copy.pos] = piece_copy
    board_copy.move!(piece_copy, pos)
    board_copy.in_check?(piece_copy.color)
  end

end