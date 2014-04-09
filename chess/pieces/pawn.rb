require_relative 'stepping_piece'

class Pawn < SteppingPiece

  MOVE_DELTAS = {
    :white => [[-1, 0]],
    :black => [[1, 0]]
  }
  DISPLAY_CHAR = "\u265F "

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