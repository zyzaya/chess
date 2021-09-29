# frozen_string_literal: true

require_relative 'pieces/bishop'
require_relative 'pieces/king'
require_relative 'pieces/knight'
require_relative 'pieces/pawn'
require_relative 'pieces/queen'
require_relative 'pieces/rook'

# A Chess board
class ChessBoard
  def initialize
    @board = reset_board
  end

  def initialize_copy(original)
    super
    @board = Array.new(8).map { Array.new(8, nil) }
    0.upto(7) do |col|
      0.upto(7) do |row|
        @board[col][row] = original.piece(col: col, row: row).clone
      end
    end
  end

  def to_input(cell = nil, **coords)
    return cell unless cell.nil?

    return nil unless
      coords[:col] >= 0 && coords[:col] <= 7 &&
      coords[:row] >= 0 && coords[:row] <= 7

    "#{(coords[:col] + 'a'.ord).chr}#{coords[:row] + 1}"
  end

  def to_coords(cell = nil, **coords)
    return coords if
      cell.nil? &&
      [coords[:col], coords[:row]].none?(&:nil?)

    cell.nil? ? { col: nil, row: nil } : { col: col(cell), row: row(cell) }
  end

  def col(val)
    return nil unless valid_cell(val)

    val[0].ord - 'a'.ord
  end

  def row(val)
    return nil unless valid_cell(val)

    val[1].to_i - 1
  end

  def reset_board
    board = Array.new(8).map { Array.new(8, nil) }
    setup_bishops(board)
    setup_kings(board)
    setup_knights(board)
    setup_pawns(board)
    setup_queens(board)
    setup_rooks(board)
    board
  end

  def move_piece(origin = nil, dest = nil, **coord)
    origin_coords = to_coords(origin, col: coord[:origin_col], row: coord[:origin_row])
    dest_coords = to_coords(dest, col: coord[:dest_col], row: coord[:dest_row])
    return unless on_board?(**origin_coords) && on_board?(**dest_coords)

    return if move_castle(origin, dest, **coord)

    return if move_pawn(origin, dest, **coord)

    @board[dest_coords[:col]][dest_coords[:row]] = piece(**origin_coords)
    @board[origin_coords[:col]][origin_coords[:row]] = nil
  end

  def move_castle(origin = nil, dest = nil, **coord)
  end

  def move_pawn(origin = nil, dest = nil, **coord)
  end

  def piece(cell = nil, **coord)
    coord = to_coords(cell, **coord)
    return nil unless on_board?(**coord)

    @board[coord[:col]][coord[:row]]
  end

  def on_board?(cell = nil, **coord)
    coord = to_coords(cell, **coord)
    return false if coord.any? { |_, v| v.nil? }

    coord[:col] >= 0 && coord[:col] < 8 &&
      coord[:row] >= 0 && coord[:row] < 8
  end

  def each_cell
    0.upto(@board.length - 1) do |col|
      0.upto(@board[col].length - 1) do |row|
        yield(piece(col: col, row: row), col, row)
      end
    end
  end

  def draw
    board = <<~BOARD

          a   b   c   d   e   f   g   h
        ┌───┬───┬───┬───┬───┬───┬───┬───┐
      x │ 8 │ 8 │ 8 │ 8 │ 8 │ 8 │ 8 │ 8 │ x
        ├───┼───┼───┼───┼───┼───┼───┼───┤
      x │ 7 │ 7 │ 7 │ 7 │ 7 │ 7 │ 7 │ 7 │ x
        ├───┼───┼───┼───┼───┼───┼───┼───┤
      x │ 6 │ 6 │ 6 │ 6 │ 6 │ 6 │ 6 │ 6 │ x
        ├───┼───┼───┼───┼───┼───┼───┼───┤
      x │ 5 │ 5 │ 5 │ 5 │ 5 │ 5 │ 5 │ 5 │ x
        ├───┼───┼───┼───┼───┼───┼───┼───┤
      x │ 4 │ 4 │ 4 │ 4 │ 4 │ 4 │ 4 │ 4 │ x
        ├───┼───┼───┼───┼───┼───┼───┼───┤
      x │ 3 │ 3 │ 3 │ 3 │ 3 │ 3 │ 3 │ 3 │ x
        ├───┼───┼───┼───┼───┼───┼───┼───┤
      x │ 2 │ 2 │ 2 │ 2 │ 2 │ 2 │ 2 │ 2 │ x
        ├───┼───┼───┼───┼───┼───┼───┼───┤
      x │ 1 │ 1 │ 1 │ 1 │ 1 │ 1 │ 1 │ 1 │ x
        └───┴───┴───┴───┴───┴───┴───┴───┘
          a   b   c   d   e   f   g   h

    BOARD
    i = 1
    each_cell do |piece|
      board =
        if piece.nil? then board.sub(i.to_s, ' ')
        else board.sub(i.to_s, piece.draw) end
      i += 1
      i = 1 if i == 9
    end
    8.downto(1) do |j|
      board = board.sub('x', j.to_s)
      board = board.sub('x', j.to_s)
    end
    board
  end

  private

  def setup_bishops(board)
    board[2][7] = Bishop.new(:black)
    board[5][7] = Bishop.new(:black)
    board[2][0] = Bishop.new(:white)
    board[5][0] = Bishop.new(:white)
  end

  def setup_kings(board)
    board[4][7] = King.new(:black)
    board[4][0] = King.new(:white)
  end

  def setup_knights(board)
    board[1][7] = Knight.new(:black)
    board[6][7] = Knight.new(:black)
    board[1][0] = Knight.new(:white)
    board[6][0] = Knight.new(:white)
  end

  def setup_pawns(board)
    0.upto(7) do |col|
      board[col][6] = Pawn.new(:black)
      board[col][1] = Pawn.new(:white)
    end
  end

  def setup_queens(board)
    board[3][7] = Queen.new(:black)
    board[3][0] = Queen.new(:white)
  end

  def setup_rooks(board)
    board[0][7] = Rook.new(:black, :left)
    board[7][7] = Rook.new(:black, :right)
    board[0][0] = Rook.new(:white, :left)
    board[7][0] = Rook.new(:white, :right)
  end

  def valid_cell(val)
    val.is_a?(String) &&
      val.length == 2 &&
      val[0].ord >= 'a'.ord &&
      val[0].ord <= 'h'.ord &&
      val[1].to_i >= 1 &&
      val[1].to_i <= 8
  end
end
