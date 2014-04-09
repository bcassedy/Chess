require_relative '../pieces.rb'

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