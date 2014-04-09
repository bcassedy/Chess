require_relative 'stepping_piece'
class King < SteppingPiece
  # MOVE_DELTAS =
  DISPLAY_CHAR = "\u265A "
  MOVE_DELTAS = [ [1, 0],
                  [-1, 0],
                  [1, 1],
                  [1, -1],
                  [-1, -1],
                  [-1, 1],
                  [0, 1],
                  [0, -1] ]

end