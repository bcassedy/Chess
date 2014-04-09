class Rook < SlidingPiece
  DISPLAY_CHAR = "\u265C "
  MOVE_DELTAS = [  [1, 0],
                   [0, 1],
                   [-1, 0],
                   [0, -1] ]

end