require_relative 'sliding_piece'

class Bishop < SlidingPiece
  DISPLAY_CHAR = "\u265D "
  MOVE_DELTAS = [  [-1, 1],
                   [1, 1],
                   [1, -1],
                   [-1, -1] ]

end