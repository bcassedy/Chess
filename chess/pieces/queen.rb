require_relative 'sliding_piece'

class Queen < SlidingPiece
  DISPLAY_CHAR = "\u265B "
  MOVE_DELTAS = [  [1, 0],
                   [-1, 0],
                   [1, 1],
                   [1, -1],
                   [-1, -1],
                   [-1, 1],
                   [0, 1],
                   [0, -1] ]

end