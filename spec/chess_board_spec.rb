# frozen_string_literal: true

require 'chess_board'

describe ChessBoard do
  subject(:chess_board) { ChessBoard.new }

  describe '#col' do
    it 'returns 0 for a, 1 for b, etc, up to 8 for h' do
      result = chess_board.col('a2')
      expect(result).to eql(0)
      result = chess_board.col('h3')
      expect(result).to eql(7)
    end

    it 'returns nil if it is not given a string' do
      result = chess_board.col(2)
      expect(result).to be(nil)
    end

    it 'returns nil if it is given a string longer than 2 characters' do
      result = chess_board.col('b2b2')
      expect(result).to be(nil)
    end

    it 'returns nil if it is given input off the board' do
      result = chess_board.col('b9')
      expect(result).to be(nil)
    end
  end

  describe '#row' do
    it 'returns one less than the integer of the second character' do
      result = chess_board.row('b2')
      expect(result).to eql(1)
    end

    it 'returns nil if it is not given a string' do
      result = chess_board.row(2)
      expect(result).to be(nil)
    end

    it 'returns nil if it is given a string longer than 2 characters' do
      result = chess_board.row('b2b2')
      expect(result).to be(nil)
    end

    it 'returns nil if it is given input off the board' do
      result = chess_board.row('i2')
      expect(result).to be(nil)
    end
  end

  describe '#reset_board' do
    let(:board) { chess_board.reset_board }

    it 'places eight black pawns on the seventh row' do
      0.upto(6) do |col|
        piece = board[col][6]
        expect(piece).to be_instance_of(Pawn)
        expect(piece.color).to eql(:black)
      end
    end

    it 'places eight white pawns on the second row' do
      0.upto(6) do |col|
        piece = board[col][1]
        expect(piece).to be_instance_of(Pawn)
        expect(piece.color).to eql(:white)
      end
    end

    it 'places one rook on each corner' do
      top_left = board[0][7]
      top_right = board[7][7]
      bottom_left = board[0][0]
      bottom_right = board[7][7]
      expect(top_left).to be_instance_of(Rook)
      expect(top_right).to be_instance_of(Rook)
      expect(bottom_left).to be_instance_of(Rook)
      expect(bottom_right).to be_instance_of(Rook)
    end

    it 'places one knight adjacent to each rook' do
      top_left = board[1][7]
      top_right = board[6][7]
      bottom_left = board[1][0]
      bottom_right = board[6][0]
      expect(top_left).to be_instance_of(Knight)
      expect(top_right).to be_instance_of(Knight)
      expect(bottom_left).to be_instance_of(Knight)
      expect(bottom_right).to be_instance_of(Knight)
    end

    it 'places one bishop adjacent to each knight' do
      top_left = board[2][7]
      top_right = board[5][7]
      bottom_left = board[2][0]
      bottom_right = board[5][7]
      expect(top_left).to be_instance_of(Bishop)
      expect(top_right).to be_instance_of(Bishop)
      expect(bottom_left).to be_instance_of(Bishop)
      expect(bottom_right).to be_instance_of(Bishop)
    end

    it 'places the king in column d' do
      black_king = board[3][7]
      white_king = board[3][0]
      expect(black_king).to be_instance_of(King)
      expect(black_king.color).to eql(:black)
      expect(white_king).to be_instance_of(King)
      expect(white_king.color).to eql(:white)
    end

    it 'places the queen in column e' do
      black_queen = board[4][7]
      white_queen = board[4][0]
      expect(black_queen).to be_instance_of(Queen)
      expect(black_queen.color).to eql(:black)
      expect(white_queen).to be_instance_of(Queen)
      expect(white_queen.color).to eql(:white)
    end
  end

  describe '#valid?' do
    let(:board) { chess_board.reset_board }

    it 'returns false if the origin is a different color' do
      color = :white
      origin = 'a7'
      dest = 'a5'
      result = chess_board.valid?(board, color, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if origin is nil' do
      color = :white
      origin = 'a5'
      dest = 'b5'
      result = chess_board.valid?(board, color, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if the destination is off of the board' do
      color = :white
      origin = 'g1'
      dest = 'e0'
      result = chess_board.valid?(board, color, origin, dest)
      expect(result).to be(false)
    end

    it 'returns false if the king remains in check' do
      allow(chess_board).to receive(:check?).and_return(true)
      color = :white
      origin = 'c2'
      dest = 'c3'
      result = chess_board.valid?(board, color, origin, dest)
      expect(result).to be(false)
    end
  end

  describe '#on_board?' do
    it 'returns false if input is invalid' do
      result = chess_board.on_board?('asfdasfg')
      expect(result).to be(false)
    end

    it 'returns false if input is off the board' do
      result = chess_board.on_board?('i8')
      expect(result).to be(false)
    end

    it 'returns true if the cell is on the board' do
      result = chess_board.on_board?('c3')
      expect(result).to be(true)
    end
  end

  describe '#valid_piece_move?' do
    let(:board) { chess_board.reset_board }
    let(:piece) { board[0][6] }

    it 'returns false if the move to dest is not a legal move by the piece at origin' do
      origin = 'a7'
      dest = 'a4'
      result = chess_board.valid_piece_move?(piece, origin, dest)
      expect(result).to be(false)
    end

    it 'returns true if the move to dest is a legal move by the piece at origin' do
      origin = 'a7'
      dest = 'a5'
      result = chess_board.valid_piece_move?(piece, origin, dest)
      expect(result).to be(true)
    end
  end

  describe '#obstructed?' do
    let(:board) { chess_board.reset_board }

    it 'returns true if there is a piece obstructing the move (except knights)' do
      origin = 'h1'
      dest = 'h3'
      result = chess_board.obstructed?(board, origin, dest)
      expect(result).to be(true)
    end

    it 'returns false if there are obstructions but the piece is a knight' do
      origin = 'b8'
      dest = 'a6'
      result = chess_board.obstructed?(board, origin, dest)
      expect(result).to be(false)
    end
  end

  describe 'removes_check?' do
    let(:board) { chess_board.reset_board }

    before do
      allow(chess_board).to receive(:check?).and_return(true)
    end

    it 'does not modify the board' do
      current = board.map { |col| col.map { |cell| cell } }
      origin = 'b8'
      dest = 'c6'
      chess_board.removes_check?(board, origin, dest)
      expect(board).to eql(current)
    end

    it 'calls check? with a board as if the move has already happened' do
      future = board.map { |col| col.map { |cell| cell } }
      origin = 'b8'
      dest = 'c6'
      future[2][5] = board[1][7]
      future[1][7] = nil
      expect(chess_board).to receive(:check?).with(eql(future), anything)
      expect(chess_board).not_to receive(:check?).with(eql(board), anything)
      chess_board.removes_check?(board, origin, dest)
    end
  end

  describe '#check?' do
    let(:board) { chess_board.reset_board }

    before do
      allow(chess_board).to receive(:find_king).and_return('d8')
    end

    it 'returns false if no piece can capture the king' do
      result = chess_board.check?(board, :black)
      expect(result).to be(false)
    end

    it 'returns true if any piece can capture the king' do
      board[4][6] = nil
      board[3][1] = nil
      board[6][4] = board[2][0]
      board[2][0] = nil
      puts "#{chess_board.valid?(board, :white, 'g5', 'd8')}"
      result = chess_board.check?(board, :black)
      expect(result).to be(true)
    end
  end
end
