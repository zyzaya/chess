# frozen_string_literal: true

# Validates chess movements
class ChessRule
  def valid?(board, color, origin = nil, dest = nil, **coords)
    origin = board.to_input(origin, col: coords[:origin_col], row: coords[:origin_row])
    dest = board.to_input(dest, col: coords[:dest_col], row: coords[:dest_col])
    return false unless taken_cell?(board, origin)

    origin_piece = board.piece(origin)
    # origin_piece.color.eql?(color) &&
    #   valid_piece_move?(board, origin_piece, origin, dest) &&
    #   !obstructed?(board, origin, dest) &&
    #   removes_check?(board, origin, dest)
    p "color: #{color}, o: #{origin}, pc: #{origin_piece.color}"
    p "check?: #{check?(board, color)}"
    return false unless origin_piece.color.eql?(color)
    p "is correct color"
    return false unless valid_piece_move?(board, origin_piece, origin, dest)
    p "is valid piece move"
    return false unless !obstructed?(board, origin, dest)
    p 'is not obstructed'
    return false unless removes_check?(board, origin, dest)
    p 'removes check'
    true
  end

  def check?(board, color)
    enemy = color.eql?(:white) ? :black : :white
    board.each_cell do |piece, col, row|
      p "cp: #{col}, #{row}" if 
        !piece.nil? && capture_king?(board, col: col, row: row)
      return true if
        piece&.color.eql?(enemy) &&
        capture_king?(board, col: col, row: row)
    end
    false
  end

  def checkmate?(board, color)
    enemy = color.eql?(:white) ? :black : :white
    king = find_king(board, color)
    board.each_cell do |piece|
      next unless !piece.nil? && piece.color.eql?(enemy)

      piece.valid.each do |v|
        return false unless obstructed?(board, nil, king, origin_col: v[0], origin_row: v[1])
      end
    end
    true
  end

  def stalemate?(board)
    return false if check?(board, :white) || check?(board, :black)

    board.each_cell do |piece, col, row|
      piece.valid.each do |v|
        return false if
          valid?(board, origin_col: col, origin_row: row,
                        dest_col: col + v[0], dest_row: row + v[1])
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

  def capture_king?(board, cell = nil, **coords)
    piece = board.piece(cell, **coords)
    enemy = piece.color ? :black : :white
    origin = board.to_input(cell, **coords)
    king = find_king(board, enemy)
    valid_piece_move?(board, piece, origin, king) &&
      !obstructed?(board, origin, king)
  end

  def find_king(board, color)
    0.upto(7) do |col|
      0.upto(7) do |row|
        piece = board.piece(col: col, row: row)
        return board.to_input(col: col, row: row) if !piece.nil? && piece.color.eql?(color)
      end
    end
  end

  def removes_check?(board, origin = nil, dest = nil, **coords)
    origin = board.to_input(origin, col: coords[:origin_col], row: coords[:origin_row])
    future = board.clone
    future.move_piece(origin, dest, **coords)
    !check?(future, board.piece(origin).color)
  end

  def valid_piece_move?(board, piece, origin = nil, dest = nil, **coords)
    origin = board.to_coords(origin, col: coords[:origin_col], row: coords[:origin_row])
    dest = board.to_coords(dest, col: coords[:dest_col], row: coords[:dest_col])
    rel_col = dest[:col] - origin[:col]
    rel_row = dest[:row] - origin[:row]
    piece.valid?(rel_col, rel_row)
  end

  def taken_cell?(board, cell = nil, **coords)
    return false unless board.on_board?(cell, **coords)

    !board.piece(cell, **coords).nil?
  end

  def obstructed?(board, origin = nil, dest = nil, **coords)
    !cells_between(board, origin, dest, **coords).all?(&:nil?)
  end

  def cells_between(board, origin = nil, dest = nil, **coords)
    origin = board.to_coords(origin, col: coords[:origin_col], row: coords[:origin_row])
    dest = board.to_coords(dest, col: coords[:dest_col], row: coords[:dest_col])
    col = origin[:col]
    row = origin[:row]
    result = []
    until col >= dest[:col] && row >= dest[:row]
      result << board.piece(col: col, row: row)
      col += 1 unless col >= dest[:col]
      row += 1 unless row >= dest[:row]
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
