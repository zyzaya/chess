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

    it 'places the queen in column d' do
      black_queen = board[3][7]
      white_queen = board[3][0]
      expect(black_queen).to be_instance_of(Queen)
      expect(black_queen.color).to eql(:black)
      expect(white_queen).to be_instance_of(Queen)
      expect(white_queen.color).to eql(:white)
    end

    it 'places the king in column e' do
      black_king = board[4][7]
      white_king = board[4][0]
      expect(black_king).to be_instance_of(King)
      expect(black_king.color).to eql(:black)
      expect(white_king).to be_instance_of(King)
      expect(white_king.color).to eql(:white)
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

    it 'returns true when input is on the board and using col, row parameters' do
      result = chess_board.on_board?(3, 4)
      expect(result).to be(true)
    end
  end

  describe '#piece' do
    before do
      allow(chess_board).to receive(:on_board?).and_return(true)
    end

    it 'returns nil if the given input is off the board' do
      allow(chess_board).to receive(:on_board?).and_return(false)
      result = chess_board.piece('a9')
      expect(result).to eql(nil)
    end

    it 'returns a piece when using a single string parameter' do
      result = chess_board.piece('b7')
      expect(result).not_to eql(nil)
    end

    it 'returns a piece when using col, row parameters' do
      result = chess_board.piece(col: 1, row: 6)
      expect(result).not_to eql(nil)
    end
  end

  describe '#move_piece' do
    origin = 'b1'
    dest = 'c3'

    before do
      allow(chess_board).to receive(:on_board?).and_return(true)
      allow(chess_board).to receive(:col).with(origin).and_return(1)
      allow(chess_board).to receive(:row).with(origin).and_return(0)
      allow(chess_board).to receive(:col).with(dest).and_return(2)
      allow(chess_board).to receive(:row).with(dest).and_return(2)
    end

    it 'sets dest to the piece at origin' do
      board = chess_board.instance_variable_get(:@board)
      piece = board[1][0]
      chess_board.move_piece(origin, dest)
      result = board[2][2]
      expect(result).to eql(piece)
    end

    it 'sets the piece at origin to nil' do
      board = chess_board.instance_variable_get(:@board)
      chess_board.move_piece(origin, dest)
      result = board[1][0]
      expect(result).to eql(nil)
    end
  end
end
