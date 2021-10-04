# frozen_string_literal: true

require 'chess_rule'
# require 'chess_board'

describe ChessRule do
  subject(:chess_rule) { ChessRule.new }

  describe '#valid?' do
    let(:white_piece) { instance_double('ChessPiece', color: :white) }
    let(:board) { instance_double('ChessBoard') }
    let(:origin) { instance_double('Cell') }
    let(:dest) { instance_double('Cell') }

    before do
      allow(board).to receive(:piece).and_return(white_piece)
      allow(chess_rule).to receive(:valid_transition?).and_return(true)
      allow(chess_rule).to receive(:valid_piece_move?).and_return(true)
      allow(chess_rule).to receive(:obstructed?).and_return(false)
      allow(chess_rule).to receive(:removes_check?).and_return(true)
    end

    it 'returns false if it is not a valid transition' do
      allow(chess_rule).to receive(:valid_transition?).and_return(false)
      result = chess_rule.valid?(board, :white, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if the origin is a different color' do
      result = chess_rule.valid?(board, :black, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if the movement is not valid for the piece' do
      allow(chess_rule).to receive(:valid_piece_move?).and_return(false)
      result = chess_rule.valid?(board, :white, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if the movement is obstructed' do
      allow(chess_rule).to receive(:obstructed?).and_return(true)
      result = chess_rule.valid?(board, :white, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if the king remains in check' do
      allow(chess_rule).to receive(:removes_check?).and_return(false)
      result = chess_rule.valid?(board, :white, origin, dest)
      expect(result).to be(false)
    end
  end

  describe '#valid_transition?' do
    let(:board) { instance_double('ChessBoard') }
    let(:origin) { instance_double('Cell') }
    let(:dest) { instance_double('Cell') }

    before do
      allow(board).to receive(:on_board?).with(dest).and_return(true)
      allow(chess_rule).to receive(:taken_cell?).with(board, origin).and_return(true)
      allow(chess_rule).to receive(:taken_cell?).with(board, dest).and_return(false)
    end

    it 'returns false if origin is not taken' do
      allow(chess_rule).to receive(:taken_cell?).with(board, origin).and_return(false)
      result = chess_rule.valid_transition?(board, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if dest is taken' do
      allow(chess_rule).to receive(:taken_cell?).with(board, dest).and_return(true)
      result = chess_rule.valid_transition?(board, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if dest is off board' do
      allow(board).to receive(:on_board?).with(dest).and_return(false)
      result = chess_rule.valid_transition?(board, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns true if origin is taken, dest is not taken, and dest is on the board' do
      result = chess_rule.valid_transition?(board, origin, dest)
      expect(result).to eql(true)
    end
  end

  describe '#removes_check?' do
    let(:board) { instance_double('ChessBoard') }
    let(:future) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece', color: :white) }
    let(:origin) { instance_double('Cell', col: 1, row: 7) }
    let(:dest) { instance_double('Cell', col: 2, row: 5) }

    before do
      allow(chess_rule).to receive(:check?).and_return(true)
      allow(chess_rule).to receive(:valid_transition?).and_return(true)
      allow(chess_rule).to receive(:valid_piece_move?).and_return(true)
      allow(chess_rule).to receive(:obstructed?).and_return(false)
      allow(chess_rule).to receive(:check?).with(future, :white).and_return(false)
      allow(board).to receive(:clone).and_return(future)
      allow(board).to receive(:piece).and_return(piece)
      allow(future).to receive(:move_piece)
    end

    it 'clones the original board' do
      expect(board).to receive(:clone)
      chess_rule.removes_check?(board, origin, dest)
    end

    it 'returns false if the move is not a valid transition' do
      allow(chess_rule).to receive(:valid_transition?).and_return(false)
      result = chess_rule.removes_check?(board, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if the move of the piece is not legal' do
      allow(chess_rule).to receive(:valid_piece_move?).and_return(false)
      result = chess_rule.removes_check?(board, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if the move is obstructed' do
      allow(chess_rule).to receive(:obstructed?).and_return(true)
      result = chess_rule.removes_check?(board, origin, dest)
      expect(result).to eql(false)
    end

    it 'moves piece from origin to dest on the future board' do
      expect(future).to receive(:move_piece).with(origin, dest)
      chess_rule.removes_check?(board, origin, dest)
    end

    it 'calls check? with a board as if the move has already happened' do
      expect(chess_rule).to receive(:check?).with(eql(future), anything)
      expect(chess_rule).not_to receive(:check?).with(eql(board), anything)
      chess_rule.removes_check?(board, 'b8', 'c6')
    end

    it 'returns true if the move is legal and removes check' do
      result = chess_rule.removes_check?(board, origin, dest)
      expect(result).to eql(true)
    end
  end

  describe '#check?' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece', color: :black) }
    let(:cell) { instance_double('Cell') }

    it 'calls capture_king once for each cell if capture_king? always returns false' do
      allow(board).to receive(:each_cell).and_yield(piece, cell)
      allow(chess_rule).to receive(:capture_king?).and_return(false)
      expect(chess_rule).to receive(:capture_king?).with(board, anything).exactly(1).times
      result = chess_rule.check?(board, :white)
      expect(result).to eql(false)
    end

    it 'returns true as soon as capture_king? returns true' do
      allow(board).to receive(:each_cell).and_yield(piece, cell).and_yield(piece, cell)
      allow(chess_rule).to receive(:capture_king?).and_return(false, true)
      expect(chess_rule).to receive(:capture_king?).with(board, anything).exactly(2).times
      result = chess_rule.check?(board, :white)
      expect(result).to eql(true)
    end
  end

  describe '#obstructed?' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece') }
    let(:knight) { instance_double('Knight') }
    let(:origin) { instance_double('Cell') }
    let(:dest) { instance_double('Cell') }

    before do
      allow(piece).to receive(:instance_of?).with(Knight).and_return(false)
      allow(knight).to receive(:instance_of?).with(Knight).and_return(true)
      allow(board).to receive(:piece).with(origin).and_return(piece)
    end

    it 'call cells between' do
      allow(chess_rule).to receive(:cells_between).and_return([nil])
      expect(chess_rule).to receive(:cells_between).with(board, origin, dest)
      chess_rule.obstructed?(board, origin, dest)
    end

    it 'returns true if there is a piece obstructing the move (except knights)' do
      allow(chess_rule).to receive(:cells_between).and_return([nil, piece])
      result = chess_rule.obstructed?(board, origin, dest)
      expect(result).to be(true)
    end

    it 'returns false if there are obstructions but the piece is a knight' do
      allow(board).to receive(:piece).with(origin).and_return(knight)
      result = chess_rule.obstructed?(board, origin, dest)
      expect(result).to be(false)
    end
  end

  describe '#valid_piece_move?' do
    let(:piece) { instance_double('ChessPiece') }
    let(:origin) { instance_double('Cell', col: 0, row: 6, input: 'a7') }
    let(:dest) { instance_double('Cell', col: 0, row: 3, input: 'a4') }
    let(:invalid) { instance_double('Cell', col: 0, row: 3, input: nil) }

    it 'calls piece#valid? with the difference between the origin and destination column' do
      expect(piece).to receive(:valid?).with(0, anything)
      chess_rule.valid_piece_move?(piece, origin, dest)
    end

    it 'calls piece#valid? with the difference between the origin and destination column' do
      expect(piece).to receive(:valid?).with(anything, -3)
      chess_rule.valid_piece_move?(piece, origin, dest)
    end

    it 'returns false if any row or column is nil' do
      result = chess_rule.valid_piece_move?(piece, invalid, dest)
      expect(result).to eql(false)
    end
  end

  describe '#cells_between' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece') }

    before do
      allow(board).to receive(:piece).and_return(nil, piece, nil)
    end

    it 'returns an array of the cells between origin and dest when horizontal' do
      origin = instance_double('Cell', col: 0, row: 4)
      dest = instance_double('Cell', col: 7, row: 4)
      result = chess_rule.cells_between(board, origin, dest)
      p result
      expect(result.length).to eql(6)
      expect(result.one?(piece)).to eql(true)
      expect(result.reject { |r| r.eql?(piece) }.all?(&:nil?)).to eql(true)
    end

    it 'returns an array of the cells between origin and dest when vertical' do
      origin = instance_double('Cell', col: 3, row: 1)
      dest = instance_double('Cell', col: 3, row: 6)
      result = chess_rule.cells_between(board, origin, dest)
      expect(result.length).to eql(4)
      expect(result.one?(piece)).to eql(true)
      expect(result.reject { |r| r.eql?(piece) }.all?(&:nil?)).to eql(true)
    end

    it 'returns an array of the cells between origin and dest when diagonal' do
      origin = instance_double('Cell', col: 0, row: 1)
      dest = instance_double('Cell', col: 6, row: 7)
      result = chess_rule.cells_between(board, origin, dest)
      expect(result.length).to eql(5)
      expect(result.one?(piece)).to eql(true)
      expect(result.reject { |r| r.eql?(piece) }.all?(&:nil?)).to eql(true)
    end

    it 'returns an array of cells when dest is left and down compared to origin' do
      origin = instance_double('Cell', col: 6, row: 7)
      dest = instance_double('Cell', col: 0, row: 1)
      result = chess_rule.cells_between(board, origin, dest)
      expect(result.length).to eql(5)
      expect(result.one?(piece)).to eql(true)
      expect(result.reject { |r| r.eql?(piece) }.all?(&:nil?)).to eql(true)
    end
  end

  describe '#capture_king?' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece', color: :white) }
    let(:origin) { instance_double('Cell', col: 3, row: 5) }
    let(:king) { instance_double('Cell', col: 4, row: 7) }

    before do
      allow(board).to receive(:piece).and_return(piece)
      allow(chess_rule).to receive(:find_king).and_return(king)
      allow(chess_rule).to receive(:valid_piece_move?).with(piece, origin, king).and_return(true)
      allow(chess_rule).to receive(:obstructed?).and_return(true)
    end

    it 'gets the piece at col, row' do
      expect(board).to receive(:piece).with(origin)
      chess_rule.capture_king?(board, origin)
    end

    it 'gets the location of the king of the opposite color when the piece is white' do
      expect(chess_rule).to receive(:find_king).with(board, :black)
      chess_rule.capture_king?(board, origin)
    end

    it 'gets the location of the king of the opposite color when the piece is white' do
      allow(piece).to receive(:color).and_return(:black)
      expect(chess_rule).to receive(:find_king).with(board, :white)
      chess_rule.capture_king?(board, origin)
    end

    it 'returns false if the pieces movement is obstructed' do
      allow(chess_rule).to receive(:obstructed?).and_return(true)
      expect(chess_rule).to receive(:obstructed?)
      result = chess_rule.capture_king?(board, origin)
      expect(result).to eql(false)
    end

    it 'checks if the piece can move to the location of the king' do
      allow(chess_rule).to receive(:obstructed?).and_return(false)
      result = chess_rule.capture_king?(board, origin)
      expect(result).to eql(true)
    end
  end

  describe '#find_king' do
    let(:board) { instance_double('ChessBoard') }
    let(:king) { instance_double('King', color: :white) }
    let(:not_king) { instance_double('ChessPiece', color: :white) }
    let(:cell) { instance_double('Cell') }

    before do
      allow(king).to receive(:instance_of?).with(King).and_return(true)
      allow(not_king).to receive(:instance_of?).with(King).and_return(false)
      allow(board).to receive(:each_cell)
        .and_yield(nil, cell)
        .and_yield(not_king, cell)
        .and_yield(king, cell)
    end

    it 'checks pieces if they are the right color' do
      expect(king).to receive(:color).once
      chess_rule.find_king(board, :white)
    end

    it 'checks pieces if they are an instance of King' do
      expect(not_king).to receive(:instance_of?).with(King).once
      chess_rule.find_king(board, :white)
    end
  end

  describe '#checkmate?' do
    let(:board) { instance_double('ChessBoard') }
    let(:cell) { instance_double('Cell', col: 1, row: 2) }
    let(:white_piece) { instance_double('ChessPiece', valid: [cell, cell], color: :white) }
    let(:black_piece) { instance_double('ChessPiece', valid: [cell, cell], color: :black) }
    let(:king) { instance_double('King', color: :white) }

    before do
      allow(chess_rule).to receive(:removes_check?).and_return(true)
      allow(chess_rule).to receive(:find_king).and_return(king)
    end

    it 'iterates over every cell' do
      allow(board).to receive(:each_cell).and_yield(nil, cell)
      expect(board).to receive(:each_cell)
      chess_rule.checkmate?(board, :white)
    end

    it 'checks if every potential move of every non-nil piece removes_check' do
      allow(board).to receive(:each_cell).and_yield(black_piece, cell)
      expect(chess_rule).to receive(:removes_check?).exactly(1).times
      chess_rule.checkmate?(board, :black)
    end

    it 'does not check pieces of the wrong color' do
      allow(board).to receive(:each_cell).and_yield(white_piece, cell)
      expect(black_piece).not_to receive(:valid)
      chess_rule.checkmate?(board, :black)
    end

    it 'returns false as soon as a legal move removes check' do
      allow(board).to receive(:each_cell)
        .and_yield(white_piece, cell)
        .and_yield(white_piece, cell)
      allow(chess_rule).to receive(:removes_check?).and_return(false, false, false, true)
      expect(chess_rule).to receive(:removes_check?).exactly(4).times
      result = chess_rule.checkmate?(board, :white)
      expect(result).to eql(false)
    end

    it 'returns true if no legal move removes check' do
      allow(board).to receive(:each_cell).and_yield(black_piece, cell)
      allow(chess_rule).to receive(:removes_check?).and_return(false)
      result = chess_rule.checkmate?(board, :black)
      expect(result).to eql(true)
    end
  end

  describe '#taken_cell?' do
    let(:board) { instance_double('ChessBoard') }
    let(:piece) { instance_double('ChessPiece') }
    let(:cell) { instance_double('Cell') }

    before do
      allow(board).to receive(:on_board?).and_return(true)
      allow(board).to receive(:piece).and_return(nil)
    end

    it 'returns false if the cell is off of the board' do
      allow(board).to receive(:on_board?).and_return(false)
      result = chess_rule.taken_cell?(board, cell)
      expect(result).to eql(false)
    end

    it 'returns false if the given cell is nil' do
      allow(board).to receive(:piece).and_return(nil)
      result = chess_rule.taken_cell?(board, cell)
      expect(result).to eql(false)
    end

    it 'returns if true if the given cell is taken' do
      allow(board).to receive(:piece).and_return(piece)
      result = chess_rule.taken_cell?(board, cell)
      expect(result).to eql(true)
    end
  end

  describe '#stalemate?' do
    let(:board) { instance_double('ChessBoard') }
    let(:cell) { instance_double('Cell', col: 1, row: 1) }
    let(:white_piece) { instance_double('ChessPiece', valid: [cell], color: :white) }
    let(:black_piece) { instance_double('ChessPiece', valid: [cell], color: :black) }

    before do
      allow(chess_rule).to receive(:check?).and_return(false)
      allow(board).to receive(:each_cell)
        .and_yield(white_piece, cell)
        .and_yield(black_piece, cell)
        .and_yield(nil, cell)
    end

    it 'returns false if white is in check' do
      allow(chess_rule).to receive(:valid?).and_return(true)
      allow(chess_rule).to receive(:check?).with(board, :white).and_return(true)
      result = chess_rule.stalemate?(board, :white)
      expect(result).to eql(false)
    end

    it 'returns false if black is in check' do
      allow(chess_rule).to receive(:valid?).and_return(true)
      allow(chess_rule).to receive(:check?).with(board, :black).and_return(true)
      result = chess_rule.stalemate?(board, :white)
      expect(result).to eql(false)
    end

    it 'returns false if there is at least one legal move available' do
      allow(chess_rule).to receive(:valid?).and_return(true)
      result = chess_rule.stalemate?(board, :black)
      expect(result).to eql(false)
    end

    it 'returns true if there is no check and no legal moves available' do
      allow(chess_rule).to receive(:valid?).with(board, :white, anything, anything).and_return(false)
      allow(chess_rule).to receive(:valid?).with(board, :black, anything, anything).and_return(true)
      result = chess_rule.stalemate?(board, :white)
      expect(result).to eql(true)
    end

    it 'returns false if the white is in stalemate but the given color (black) is not' do
      allow(chess_rule).to receive(:valid?).with(board, :white, anything, anything).and_return(false)
      allow(chess_rule).to receive(:valid?).with(board, :black, anything, anything).and_return(true)
      result = chess_rule.stalemate?(board, :black)
      expect(result).to eql(false)
    end
  end

  describe '#dead_position?' do
    let(:board) { instance_double('ChessBoard') }
    let(:black_king) { instance_double('King', color: :black, instance_of?: false) }
    let(:white_king) { instance_double('King', color: :white, instance_of?: false) }
    let(:bishop) { instance_double('Bishop', color: :white, instance_of?: false) }
    let(:knight) { instance_double('Knight', color: :white,instance_of?: false) }

    before do
      allow(black_king).to receive(:instance_of?).with(King).and_return(true)
      allow(white_king).to receive(:instance_of?).with(King).and_return(true)
      allow(bishop).to receive(:instance_of?).with(Bishop).and_return(true)
      allow(knight).to receive(:instance_of?).with(Knight).and_return(true)
    end

    it 'returns true if only two kings remain' do
      allow(board).to receive(:each_cell)
        .and_yield(white_king)
        .and_yield(black_king)
        .and_yield(nil)
      result = chess_rule.dead_position?(board)
      expect(result).to eql(true)
    end

    it 'returns true if only a king against king and bishop remain' do
      allow(board).to receive(:each_cell)
        .and_yield(white_king)
        .and_yield(black_king)
        .and_yield(bishop)
        .and_yield(nil)
      result = chess_rule.dead_position?(board)
      expect(result).to eql(true)
    end

    it 'returns true if only a king against a king and knight remain' do
      allow(board).to receive(:each_cell)
        .and_yield(white_king)
        .and_yield(black_king)
        .and_yield(knight)
        .and_yield(nil)
      result = chess_rule.dead_position?(board)
      expect(result).to eql(true)
    end

    it 'returns false if no dead position' do
      allow(board).to receive(:each_cell)
        .and_yield(white_king)
        .and_yield(black_king)
        .and_yield(bishop)
        .and_yield(knight)
      result = chess_rule.dead_position?(board)
      expect(result).to eql(true)
    end
  end
end
