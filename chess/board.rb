require_relative 'pieces'

class Board

  def initialize(board = nil)
    @board = board || Array.new(8) { Array.new(8) }
    if board.nil?
      setup_board
    end
  end

  def setup_board
    pieces = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook]
    pieces.each_with_index do |piece, col|
      self[[0, col]] = piece.new(self, :black, [0, col])
      self[[7, col]] = piece.new(self, :white, [7, col])
    end
    @board[1].each_index do |col|
      self[[1, col]] = Pawn.new(self, :black, [1, col])
      self[[6, col]] = Pawn.new(self, :white, [6, col])
    end
  end

  def deep_dup
    arr = Array.new(8) { Array.new(8) }
    board_copy = Board.new(arr)
    @board.each do |row|
      new_row = []
      row.each do |space|
        if !space.nil?
          board_copy[space.pos] = space.class
                        .new(board_copy, space.color, space.pos)
        end
      end
    end
    board_copy
  end

  def locate_king(color)
    @board.each do |row|
      row.each do |space|
        next if space.nil?
        next if space.color != color
        return space.pos if space.is_a?(King)
      end
    end
  end

  def [](pos)
    row, col = pos
    @board[row][col]
  end

  def []=(pos, piece)
    row, col = pos
    @board[row][col] = piece
  end

  def move(start_pos, end_pos)
    raise "Position off board" if out_of_bounds?(start_pos) ||
                                  out_of_bounds?(end_pos)
    piece = self[start_pos]
    raise "Not a valid move for this piece" unless piece.moves.include?(end_pos)
    raise "Move would put you in check" unless piece
                .valid_moves(piece.moves).include?(end_pos)
    move!(piece, end_pos)
  end

  def move!(piece, new_pos)
    self[piece.pos] = nil
    self[new_pos] = piece
    piece.pos = new_pos
  end

  def out_of_bounds?(pos)
    return true if pos.any? { |coord| coord > 7 || coord < 0 }
    false
  end

  def to_s
    next_color = { :green => :white, :white => :green }
    output = "   a b c d e f g h\n "
    cur_color = :white
    @board.each_with_index do |row, row_index|
      #lookup x coord of given row_index
      cur_color = next_color[cur_color]
      output += "#{8 - row_index} "
      row.each do |space|
        if space.nil?
          output += "  ".colorize(:background => cur_color)
        else
          output += space.display_char.colorize(:color => space.color,
          :background => cur_color)
        end
        cur_color = next_color[cur_color]
      end
      output += "#{8 - row_index}"
      output += "\n "
    end
    output += "  a b c d e f g h\n "
    output
  end

  def in_check?(color)
    king_pos = locate_king(color)

    @board.each do |row|
      row.each do |space|
        next if space.nil? || space.color == color
        return true if space.moves.any? { |move| move == king_pos }
      end
    end
    false
  end

  def checkmate?(color)
    @board.each do |row|
      row.each do |space|
        next if space.nil?
        next if space.color != color
        return false unless space.valid_moves(space.moves).empty?
      end
    end
    true
  end

end
