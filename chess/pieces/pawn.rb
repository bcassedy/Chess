require_relative 'stepping_piece'
require 'debugger'

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
    possible_moves = deltas
    possible_moves += [[2,0], [-2,0]] if @moves_num == 0
    possible_moves.each do |delta|
      new_row = @pos[0] + delta[0]
      new_col = @pos[1] + delta[1]
      move = [new_row, new_col]
      if valid?(move) || diagonal_captures.include?(move)
        moves << move
      end
    end
    moves + diagonal_captures
  end

  def deltas
    MOVE_DELTAS[color]
  end

  private

  def diagonal_captures
    diagonal_moves = []
    row_delta = MOVE_DELTAS[@color][0][0]
    diagonal_moves << [row_delta + self.pos[0], self.pos[1] + 1]
    diagonal_moves << [row_delta + self.pos[0], self.pos[1] - 1]

    diagonal_moves.select do |move|
      !(@board[move].nil?) && capture_possible?(move)
    end
  end
end