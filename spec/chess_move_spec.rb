# frozen_string_literal: true

require 'chess_move'

describe ChessMove do
  let(:chess_move) { ChessMove.new }
  let(:rule) { instance_double('ChessRule', valid?: true) }
  let(:board) { instance_double('ChessBoard') }
  let(:piece) { instance_double('ChessPiece', color: :white) }
  let(:origin) { instance_double('Cell', col: 0, row: 0) }
  let(:dest) { instance_double('Cell', col: 1, row: 1) }

  describe '#move_piece' do
    before do
      allow(chess_move).to receive(:move_castle).and_return(false)
      allow(chess_move).to receive(:move_pawn).and_return(false)
      allow(board).to receive(:piece).and_return(piece)
    end

    it 'raises an error if the given move is not valid' do
      allow(rule).to receive(:valid?).and_return(false)
      expect do
        chess_move.move_piece(board, rule, origin, dest)
      end.to raise_exception(ArgumentError)
    end

    it 'tries to castle' do
      expect(chess_move).to receive(:move_castle)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'returns if it castled' do
      allow(chess_move).to receive(:move_castle).and_return(true)
      expect(chess_move).not_to receive(:generic_move)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'tries to move a pawn' do
      expect(chess_move).to receive(:move_pawn)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'returns if it moved a pawn' do
      allow(chess_move).to receive(:move_pawn).and_return(true)
      expect(chess_move).not_to receive(:generic_move)
      chess_move.move_piece(board, rule, origin, dest)
    end

    it 'calls generic move if the move is legal, is not castling, and is not a pawn' do
      expect(chess_move).to receive(:generic_move)
      chess_move.move_piece(board, rule, origin, dest)
    end
  end

  describe '#move_castle' do
    before do
      allow(chess_move).to receive(:can_castle?).and_return(true)
      allow(chess_move).to receive(:castle)
    end

    it 'returns false if the castle is not legal' do
      allow(chess_move).to receive(:can_castle?).and_return(false)
      result = chess_move.move_castle(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'castles if the movement is a legal castle' do
      result = chess_move.move_castle(board, rule, origin, dest)
      expect(result).to eql(true)
    end
  end

  describe 'castling?' do
    let(:king) { instance_double('King', instance_of?: false) }
    let(:not_king) { instance_double('ChessPiece', instance_of?: false) }
    let(:origin) { instance_double('Cell', col: 4, row: 0) }
    let(:dest) { instance_double('Cell', col: 1, row: 0) }

    before do
      allow(board).to receive(:piece).and_return(king)
      allow(king).to receive(:instance_of?).with(King).and_return(true)
    end

    it 'returns false if piece is not a king' do
      allow(board).to receive(:piece).and_return(not_king)
      result = chess_move.castling?(board, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if the movement is not castling' do
      not_castle = instance_double('Cell', col: 5, row: 5)
      result = chess_move.castling?(board, origin, not_castle)
      expect(result).to eql(false)
    end

    it 'returns true if the the movemenet is castling' do
      result = chess_move.castling?(board, origin, dest)
      expect(result).to eql(true)
    end
  end

  describe '#can_castle?' do
    let(:king) { instance_double('King', moved: false) }
    let(:rook) { instance_double('Rook', moved: false) }
    let(:rook_cell) { instance_double('Cell', col: 0, row: 0) }
    let(:origin) { instance_double('Cell', col: 4, row: 0) }
    let(:dest) { instance_double('Cell', col: 1, row: 0) }

    before do
      allow(chess_move).to receive(:castling?).and_return(true)
      allow(chess_move).to receive(:find_castling_rook).and_return(rook_cell)
      allow(chess_move).to receive(:castle_in_check?).and_return(false)
      allow(rule).to receive(:obstructed?).and_return(false)
      allow(board).to receive(:piece).with(origin).and_return(king)
      allow(board).to receive(:piece).with(rook_cell).and_return(rook)
    end

    it 'returns false if the move is not castling' do
      allow(chess_move).to receive(:castling?).and_return(false)
      result = chess_move.can_castle?(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if the king has moved' do
      allow(king).to receive(:moved).and_return(true)
      result = chess_move.can_castle?(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if the rook has moved' do
      allow(rook).to receive(:moved).and_return(true)
      result = chess_move.can_castle?(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if any of the cells between the king and rook are taken' do
      allow(rule).to receive(:obstructed?).and_return(true)
      result = chess_move.can_castle?(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns false if any the cells the king moves through are in check' do
      allow(chess_move).to receive(:castle_in_check?).and_return(true)
      result = chess_move.can_castle?(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns true when the castling is valid' do
      result = chess_move.can_castle?(board, rule, origin, dest)
      expect(result).to eql(true)
    end
  end

  describe '#find_castling_rook' do
    it 'returns the related rook for the given destination' do
      destinations = %w[c8 g8 c1 g1]
      rooks = %w[a8 h8 a1 h1]
      destinations.each.with_index do |d, i|
        dest = instance_double('Cell', input: d)
        result = chess_move.find_castling_rook(dest)
        expect(result.input).to eql(rooks[i])
      end
    end

    it 'returns nil if the destination is not a castling destination' do
      dest = instance_double('Cell', input: 'b7')
      result = chess_move.find_castling_rook(dest)
      expect(result).to eql(nil)
    end
  end

  describe '#find_castling_rook_destination' do
    it 'returns the related rook for the given destination' do
      rooks = %w[a8 h8 a1 h1]
      destinations = %w[d8 f8 d1 f1]
      rooks.each.with_index do |d, i|
        rook = instance_double('Cell', input: d)
        result = chess_move.find_castling_rook_destination(rook)
        expect(result.input).to eql(destinations[i])
      end
    end

    it 'returns nil if the destination is not a castling destination' do
      dest = instance_double('Cell', input: 'b7')
      result = chess_move.find_castling_rook_destination(dest)
      expect(result).to eql(nil)
    end
  end

  describe '#castle_in_check' do
    let(:future) { instance_double('ChessBoard') }
    let(:piece) { instance_double('King', color: :black) }
    let(:king) { instance_double('Cell', col: 4, row: 7, input: 'e8') }
    let(:dest) { instance_double('Cell', col: 0, row: 7, input: 'a8') }

    before do
      allow(board).to receive(:clone).and_return(future)
      allow(board).to receive(:piece).and_return(piece)
      allow(future).to receive(:move_piece)
      allow(rule).to receive(:check?).and_return(false)
      allow(king).to receive(:input=)
      allow(dest).to receive(:input=)
    end

    it 'iterates over every cell between king and rook' do
      expect(future).to receive(:move_piece).exactly(3).times
      chess_move.castle_in_check?(board, rule, king, dest)
    end

    it 'works on a clone of board' do
      expect(board).to receive(:clone)
      chess_move.castle_in_check?(board, rule, king, dest)
    end

    it 'places king in each cell and checks if it is in check' do
      expect(rule).to receive(:check?).exactly(3).times
      chess_move.castle_in_check?(board, rule, king, dest)
    end

    it 'returns true if any cell the king passes through is in check' do
      allow(rule).to receive(:check?).and_return(true)
      result = chess_move.castle_in_check?(board, rule, king, dest)
      expect(result).to eql(true)
    end

    it 'returns false if no cell the king passes through is in check' do
      result = chess_move.castle_in_check?(board, rule, king, dest)
      expect(result).to eql(false)
    end
  end

  describe 'castle' do
    let(:origin) { instance_double('Cell', col: 4, row: 7, input: 'e8') }
    let(:dest) { instance_double('Cell', col: 0, row: 7, input: 'a8') }

    before do
      allow(chess_move).to receive(:can_castle?).and_return(true)

    end

    it 'returns false if the castle is not legal' do
      allow(chess_move).to receive(:can_castle?).and_return(true)
      result = castle(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns true if it successfully castled' do
      result = castle(board, rule, origin, dest)
      expect(result).to eql(true)
    end

    it 'moves the king to destination' do
      expect(board).to receive(:move_piece).with(origin, dest)
      castle(board, rule, origin, dest)
    end

    it 'moves the relevant rook to its destination' do
      
    end
  end
end
