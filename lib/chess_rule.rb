# frozen_string_literal: true

require_relative 'cell'

# Validates chess movements
class ChessRule
  def valid?(board, color, origin, dest)
    return false unless valid_transition?(board, origin, dest)
    p 'is valid transition'
    origin_piece = board.piece(origin)
    return false unless origin_piece.color.eql?(color)
    p 'is correct color'
    return false unless valid_piece_move?(origin_piece, origin, dest)
    p 'is valid piece move'
    return false if obstructed?(board, origin, dest)
    p 'is not obstructed'
    return false unless removes_check?(board, origin, dest)
    p 'removes check'
    true
  end

  def valid_transition?(board, origin, dest)
    return false unless taken_cell?(board, origin)
    p 'origin is taken'
    enemy = board.piece(origin).color.eql?(:black) ? :white : :black
    board.on_board?(dest) &&
      (!taken_cell?(board, dest) ||
      board.piece(dest)&.color.eql?(enemy))
  end

  def check?(board, color)
    enemy = color.eql?(:white) ? :black : :white
    board.each_cell do |piece, cell|
      return true if
        piece&.color.eql?(enemy) &&
        capture_king?(board, cell)
    end
    false
  end

  def checkmate?(board, color)
    dest = Cell.new(col: 0, row: 0)
    board.each_cell do |piece, cell|
      next unless !piece.nil? && piece.color.eql?(color)

      piece.valid.each do |v|
        dest.coords(cell.col + v.col, cell.row + v.row)
        return false if removes_check?(board, cell, dest)
      end
    end
    true
  end

  def stalemate?(board, color)
    dest = Cell.new(col: 0, row: 0)
    return false if check?(board, :white) || check?(board, :black)

    board.each_cell do |piece, cell|
      next if piece.nil? || !piece.color.eql?(color)

      piece.valid.each do |v|
        dest.coords(cell.col + v.col, cell.row + v.row)
        return false if valid?(board, piece.color, cell, dest)
      end
    end
    true
  end

  def dead_position?(board)
    pieces = []
    board.each_cell do |piece|
      pieces << piece unless piece.nil?
    end
    only_kings?(pieces) ||
      only_kings_and_one_bishop?(pieces) ||
      only_kings_and_one_knight?(pieces)
  end

  def capture_king?(board, origin)
    piece = board.piece(origin)
    enemy = piece.color.eql?(:white) ? :black : :white
    king = find_king(board, enemy)
    valid_piece_move?(piece, origin, king) &&
      !obstructed?(board, origin, king)
  end

  def find_king(board, color)
    board.each_cell do |piece, cell|
      return cell if piece&.color.eql?(color) && piece.instance_of?(King)
    end
  end

  def removes_check?(board, origin, dest)
    return false unless valid_transition?(board, origin, dest)

    piece = board.piece(origin)
    return false unless
      valid_piece_move?(piece, origin, dest) &&
      !obstructed?(board, origin, dest)

    future = board.clone
    future.move_piece(origin, dest)
    !check?(future, piece.color)
  end

  def valid_piece_move?(piece, origin, dest)
    return false if [origin.input, dest.input].any?(&:nil?)

    relative = piece.relative(origin, dest)
    piece.valid?(relative.col, relative.row)
  end

  def taken_cell?(board, cell)
    return false unless board.on_board?(cell)

    !board.piece(cell).nil?
  end

  def obstructed?(board, origin, dest)
    return false if board.piece(origin).instance_of?(Knight)

    !cells_between(board, origin, dest).all?(&:nil?)
  end

  def cells_between(board, origin, dest)
    current = Cell.new(col: origin.col, row: origin.row)
    col_i = dest.col >= origin.col ? 1 : -1
    row_i = dest.row >= origin.row ? 1 : -1
    result = []
    until current.col == dest.col && current.row == dest.row
      result << board.piece(current)
      current.col += col_i unless current.col == dest.col
      current.row += row_i unless current.row == dest.row
    end
    result.drop(1)
  end

  private

  def only_kings?(pieces)
    pieces.length == 2 &&
      pieces.one? { |p| p.instance_of?(King) && p.color.eql?(:white) } &&
      pieces.one? { |p| p.instance_of?(King) && p.color.eql?(:black) }
  end

  def only_kings_and_one_bishop?(pieces)
    pieces.one? { |p| p.instance_of?(King) && p.color.eql?(:white) } &&
      pieces.one? { |p| p.instance_of?(King) && p.color.eql?(:black) } &&
      pieces.one? { |p| p.instance_of?(Bishop) }
  end

  def only_kings_and_one_knight?(pieces)
    pieces.one? { |p| p.instance_of?(King) && p.color.eql?(:white) } &&
      pieces.one? { |p| p.instance_of?(King) && p.color.eql?(:black) } &&
      pieces.one? { |p| p.instance_of?(Knight) }
  end
end
