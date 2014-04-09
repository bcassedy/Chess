require_relative 'stepping_piece'

class Knight < SteppingPiece
  MOVE_DELTAS = [ [2, 1],
                   [2, -1],
                   [-2, 1],
                   [-2, -1],
                   [-1, 2],
                   [-1, -2],
                   [1, 2],
                   [1, -2] ]
  DISPLAY_CHAR = "\u265E "
end