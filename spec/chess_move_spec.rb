# frozen_string_literal: true

require 'chess_move'

describe ChessMove do
  let(:chess_move) { ChessMove.new }
  let(:rule) { instance_double('ChessRule', valid?: true) }
  let(:board) { instance_double('ChessBoard') }
  let(:piece) { instance_double('ChessPiece', color: :white, instance_of?: false) }
  let(:pawn) { instance_double('Pawn', color: :white, instance_of?: false) }
  let(:origin) { instance_double('Cell', col: 0, row: 0) }
  let(:dest) { instance_double('Cell', col: 1, row: 1) }
  let(:input) { instance_double('ChessInput') }

  describe '#move_piece' do
    before do
      allow(chess_move).to receive(:castle).and_return(false)
      allow(chess_move).to receive(:move_pawn).and_return(false)
      allow(chess_move).to receive(:remove_en_passant)
      allow(chess_move).to receive(:update_pawn_captures)
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      allow(board).to receive(:piece).and_return(piece)
      allow(board).to receive(:move_piece)
    end

    it 'raises an error if the given move is not valid' do
      allow(rule).to receive(:valid?).and_return(false)
      expect do
        chess_move.move_piece(input, board, rule, origin, dest)
      end.to raise_exception(ArgumentError)
    end

    it 'updates en_passant if the move is a double by a pawn' do
      allow(board).to receive(:piece).and_return(pawn)
      allow(pawn).to receive(:double_move?).and_return(true)
      expect(chess_move).to receive(:update_en_passant)
      chess_move.move_piece(input, board, rule, origin, dest)
    end

    it 'updates pawn capture movements' do
      expect(chess_move).to receive(:update_pawn_captures)
      chess_move.move_piece(input, board, rule, origin, dest)
    end

    it 'tries to castle' do
      expect(chess_move).to receive(:castle)
      chess_move.move_piece(input, board, rule, origin, dest)
    end

    it 'returns if it castled' do
      allow(chess_move).to receive(:castle).and_return(true)
      expect(board).not_to receive(:move_piece)
      chess_move.move_piece(input, board, rule, origin, dest)
    end

    it 'tries to move a pawn' do
      expect(chess_move).to receive(:move_pawn)
      chess_move.move_piece(input, board, rule, origin, dest)
    end

    it 'returns if it moved a pawn' do
      allow(chess_move).to receive(:move_pawn).and_return(true)
      expect(board).not_to receive(:move_piece)
      chess_move.move_piece(input, board, rule, origin, dest)
    end

    it 'moves a piece if the move is legal, is not castling, and is not a pawn' do
      expect(board).to receive(:move_piece).with(origin, dest)
      chess_move.move_piece(input, board, rule, origin, dest)
    end
  end

  describe 'castling?' do
    let(:king) { instance_double('King', instance_of?: false) }
    let(:not_king) { instance_double('ChessPiece', instance_of?: false) }
    let(:origin) { instance_double('Cell', col: 4, row: 0) }
    let(:dest) { instance_double('Cell', col: 2, row: 0) }

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

    it 'returns true if the the movement is castling' do
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
      allow(king).to receive(:castling_rook).and_return(rook_cell)
      allow(chess_move).to receive(:castling?).and_return(true)
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

  describe '#castle' do
    let(:king) { instance_double('King') }
    let(:origin) { instance_double('Cell', col: 4, row: 7, input: 'e8') }
    let(:dest) { instance_double('Cell', col: 0, row: 7, input: 'a8') }
    let(:rook_origin) { instance_double('Cell', col: 0, row: 7, input: 'a8') }
    let(:rook_dest) { instance_double('Cell', col: 3, row: 7, input: 'd8') }

    before do
      allow(chess_move).to receive(:can_castle?).and_return(true)
      allow(king).to receive(:castling_rook).with(dest).and_return(rook_origin)
      allow(king).to receive(:castling_rook_destination).with(rook_origin).and_return(rook_dest)
      allow(board).to receive(:piece).with(origin).and_return(king)
      allow(board).to receive(:move_piece).with(origin, dest)
      allow(board).to receive(:move_piece).with(rook_origin, rook_dest)
    end

    it 'returns false if the castle is not legal' do
      allow(chess_move).to receive(:can_castle?).and_return(false)
      result = chess_move.castle(board, rule, origin, dest)
      expect(result).to eql(false)
    end

    it 'returns true if it successfully castled' do
      result = chess_move.castle(board, rule, origin, dest)
      expect(result).to eql(true)
    end

    it 'moves the king to destination' do
      expect(board).to receive(:move_piece).with(origin, dest)
      chess_move.castle(board, rule, origin, dest)
    end

    it 'moves the relevant rook to its destination' do
      expect(board).to receive(:move_piece).with(rook_origin, rook_dest)
      chess_move.castle(board, rule, origin, dest)
    end
  end

  describe '#remove_en_passant' do
    let(:pawn) { instance_double('Pawn') }
    let(:not_pawn) { instance_double('Rook') }

    before do
      allow(board).to receive(:each_cell)
        .and_yield(pawn)
        .and_yield(not_pawn)
        .and_yield(nil)
      allow(not_pawn).to receive(:instance_of?).and_return(false)
      allow(pawn).to receive(:remove_en_passant)
      allow(pawn).to receive(:instance_of?).and_return(false)
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
    end

    it 'iterates through all cells' do
      expect(board).to receive(:each_cell)
      chess_move.remove_en_passant(board)
    end

    it 'removes en_passant if the piece is a pawn' do
      expect(pawn).to receive(:remove_en_passant)
      chess_move.remove_en_passant(board)
    end

    it 'does nothing if the piece is not a pawn' do
      chess_move.remove_en_passant(board)
    end
  end

  describe '#update_pawn_captures' do
    let(:white_pawn) { instance_double('Pawn', color: :white) }
    let(:black_pawn) { instance_double('Pawn', color: :black) }
    let(:white_piece) { instance_double('Rook', color: :white, instance_of?: false) }
    let(:black_piece) { instance_double('Rook', color: :black, instance_of?: false) }
    let(:cell) { instance_double('Cell') }

    before do
      allow(white_pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      allow(white_pawn).to receive(:add_capture)
      allow(white_pawn).to receive(:remove_capture)
      allow(white_pawn).to receive(:add_all_captures)

      allow(black_pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      allow(black_pawn).to receive(:add_capture)
      allow(black_pawn).to receive(:remove_capture)
      allow(black_pawn).to receive(:add_all_captures)

      allow(board).to receive(:piece).and_return(nil)
      allow(board).to receive(:on_board?).and_return(true)
      allow(board).to receive(:each_cell)
        .and_yield(nil, cell)
        .and_yield(white_pawn, cell)
        .and_yield(black_piece, cell)
        .and_yield(black_pawn, cell)
        .and_yield(white_piece, cell)
    end

    it 'iterates through all cells' do
      expect(board).to receive(:each_cell)
      chess_move.update_pawn_captures(board)
    end

    it 'removes captures for each pawn' do
      expect(white_pawn).to receive(:remove_capture).with(:left)
      expect(white_pawn).to receive(:remove_capture).with(:right)
      expect(black_pawn).to receive(:remove_capture).with(:left)
      expect(black_pawn).to receive(:remove_capture).with(:right)
      chess_move.update_pawn_captures(board)
    end

    it 'adds captures to the pawn' do
      expect(white_pawn).to receive(:add_all_captures)
      expect(black_pawn).to receive(:add_all_captures)
      chess_move.update_pawn_captures(board)
    end
  end

  describe '#move_pawn' do
    let(:pawn) { instance_double('Pawn') }
    let(:not_pawn) { instance_double('Rook', instance_of?: false) }
    let(:origin) { instance_double('Cell') }
    let(:dest) { instance_double('Cell') }
    let(:input) { instance_double('ChessInput') }

    before do
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
      allow(pawn).to receive(:double_move?).and_return(false)
      allow(pawn).to receive(:promote?).and_return(false)
      allow(pawn).to receive(:en_passant?).and_return(false)
      allow(board).to receive(:piece).with(origin).and_return(pawn)
      allow(board).to receive(:move_piece)
    end

    it 'returns false if the piece at origin is not a pawn' do
      allow(board).to receive(:piece).with(origin).and_return(not_pawn)
      result = chess_move.move_pawn(input, board, origin, dest)
      expect(result).to eql(false)
    end

    it 'moves the piece if it is a pawn' do
      expect(board).to receive(:move_piece).with(origin, dest)
      chess_move.move_pawn(input, board, origin, dest)
    end

    it 'returns true if it moved a pawn' do
      result = chess_move.move_pawn(input, board, origin, dest)
      expect(result).to eql(true)
    end

    it 'promotes a pawn when it arrives at the final row' do
      allow(pawn).to receive(:promote?).and_return(true)
      expect(chess_move).to receive(:promote_piece).with(input, board, dest)
      chess_move.move_pawn(input, board, origin, dest)
    end

    it 'captures the pawn when moving by en passant' do
      allow(pawn).to receive(:en_passant?).and_return(true)
      expect(chess_move).to receive(:capture_by_en_passant)
      chess_move.move_pawn(input, board, origin, dest)
    end
  end

  describe '#update_en_passant' do
    let(:pawn) { instance_double('Pawn', color: :white) }
    let(:enemy) { instance_double('Pawn', color: :black) }
    let(:cell) { instance_double('Cell') }
    let(:left) { instance_double('Cell') }
    let(:right) { instance_double('Cell') }

    before do
      allow(chess_move).to receive(:remove_en_passant)
      allow(board).to receive(:piece).and_return(nil)
      allow(board).to receive(:piece).with(cell).and_return(pawn)
      allow(cell).to receive(:adjacent).with(:left).and_return(left)
      allow(cell).to receive(:adjacent).with(:right).and_return(right)
      allow(enemy).to receive(:instance_of?).with(Pawn).and_return(true)
      allow(enemy).to receive(:en_passant)
    end

    it 'removes en passant' do
      expect(chess_move).to receive(:remove_en_passant)
      chess_move.update_en_passant(board, cell)
    end

    it 'adds en_passant(left) to right piece if it is an enemy' do
      allow(board).to receive(:piece).with(right).and_return(enemy)
      expect(enemy).to receive(:en_passant).with(:left)
      chess_move.update_en_passant(board, cell)
    end

    it 'adds en_passant(right) to the left piece if it is an enemy' do
      allow(board).to receive(:piece).with(left).and_return(enemy)
      expect(enemy).to receive(:en_passant).with(:right)
      chess_move.update_en_passant(board, cell)
    end

    it 'does nothing if no adjacent pieces are enemies' do
      expect(pawn).not_to receive(:en_passant)
      chess_move.update_en_passant(board, cell)
    end
  end

  describe '#promote_piece' do
    let(:input) { instance_double('ChessInput') }
    let(:cell) { instance_double('Cell') }
    let(:piece) { instance_double('ChessPiece', color: :white) }

    before do
      allow(board).to receive(:piece).and_return(piece)
      allow(board).to receive(:force_piece)
    end

    it 'sets dest to a bishop when input is input' do
      allow(input).to receive(:promote).and_return('bishop')
      expect(board).to receive(:force_piece).with(cell, instance_of(Bishop))
      chess_move.promote_piece(input, board, cell)
    end

    it 'sets dest to a knight when input is input' do
      allow(input).to receive(:promote).and_return('knight')
      expect(board).to receive(:force_piece).with(cell, instance_of(Knight))
      chess_move.promote_piece(input, board, cell)
    end

    it 'sets dest to a queen when input is input' do
      allow(input).to receive(:promote).and_return('queen')
      expect(board).to receive(:force_piece).with(cell, instance_of(Queen))
      chess_move.promote_piece(input, board, cell)
    end

    it 'sets dest to a rook when input is input' do
      allow(input).to receive(:promote).and_return('rook')
      expect(board).to receive(:force_piece).with(cell, instance_of(Rook))
      chess_move.promote_piece(input, board, cell)
    end
  end

  describe '#capture_by_en_passant' do
    let(:origin) { instance_double('Cell') }
    let(:dest) { instance_double('Cell') }
    let(:down) { instance_double('Cell') }
    let(:up) { instance_double('Cell') }
    let(:white_piece) { instance_double('Pawn', color: :white) }
    let(:black_piece) { instance_double('Pawn', color: :black) }

    before do
      allow(dest).to receive(:adjacent).with(:down).and_return(down)
      allow(dest).to receive(:adjacent).with(:up).and_return(up)
    end

    it 'sets the row below the dest to nil if the origin is white' do
      allow(board).to receive(:piece).with(origin).and_return(white_piece)
      expect(board).to receive(:force_piece).with(down, nil)
      chess_move.capture_by_en_passant(board, origin, dest)
    end

    it 'sets the row above the dest to nil if the origin is black' do
      allow(board).to receive(:piece).with(origin).and_return(black_piece)
      expect(board).to receive(:force_piece).with(up, nil)
      chess_move.capture_by_en_passant(board, origin, dest)
    end
  end
end
