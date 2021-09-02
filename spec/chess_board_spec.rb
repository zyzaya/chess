# frozen_string_literal: true

require 'chess_board'

describe ChessBoard do
  subject(:board) { ChessBoard.new }

  describe '#col' do
    it 'returns one less than the integer of the second character' do
      result = board.col('b2')
      expect(result).to eql(1)
    end

    it 'returns nil if it is not given a string' do
      result = board.col(2)
      expect(result).to be(nil)
    end

    it 'returns nil if it is given a string longer than 2 characters' do
      result = board.col('b2b2')
      expect(result).to be(nil)
    end

    it 'returns nil if it is given input off the board' do
      result = board.col('b9')
      expect(result).to be(nil)
    end
  end

  describe '#row' do
    it 'returns 0 for a, 1 for b, etc, up to 8 for h' do
      result = board.row('a2')
      expect(result).to eql(0)
      result = board.row('h3')
      expect(result).to eql(7)
    end

    it 'returns nil if it is not given a string' do
      result = board.row(2)
      expect(result).to be(nil)
    end

    it 'returns nil if it is given a string longer than 2 characters' do
      result = board.row('b2b2')
      expect(result).to be(nil)
    end

    it 'returns nil if it is given input off the board' do
      result = board.row('i2')
      expect(result).to be(nil)
    end    
  end

  describe '#reset_board' do
    let(:new_board) { board.reset_board }
    
    it 'places eight black pawns on the seventh row' do
      0.upto(6) do |col|
        piece = new_board[col][6]
        expect(piece).to be_instance_of(Pawn)
        expect(piece.color).to eql(:black)
      end
    end
    
    it 'places eight white pawns on the second row' do
      0.upto(6) do |col|
        piece = new_board[col][1]
        expect(piece).to be_instance_of(Pawn)
        expect(piece.color).to eql(:white)
      end
    end

    it 'places one rook on each corner' do
      top_left = new_board[0][7]
      top_right = new_board[7][7]
      bottom_left = new_board[0][0]
      bottom_right = new_board[7][7]
      expect(top_left).to be_instance_of(Rook)
      expect(top_right).to be_instance_of(Rook)
      expect(bottom_left).to be_instance_of(Rook)
      expect(bottom_right).to be_instance_of(Rook)
    end

    it 'places one knight adjacent to each rook' do
      top_left = new_board[1][7]
      top_right = new_board[6][7]
      bottom_left = new_board[1][0]
      bottom_right = new_board[6][0]
      expect(top_left).to be_instance_of(Knight)
      expect(top_right).to be_instance_of(Knight)
      expect(bottom_left).to be_instance_of(Knight)
      expect(bottom_right).to be_instance_of(Knight)
    end

    it 'places one bishop adjacent to each knight' do
      top_left = new_board[2][7]
      top_right = new_board[5][7]
      bottom_left = new_board[2][0]
      bottom_right = new_board[5][7]
      expect(top_left).to be_instance_of(Bishop)
      expect(top_right).to be_instance_of(Bishop)
      expect(bottom_left).to be_instance_of(Bishop)
      expect(bottom_right).to be_instance_of(Bishop)
    end

    it 'places the king in column d' do
      black_king = new_board[3][7]
      white_king = new_board[3][0]
      expect(black_king).to be_instance_of(King)
      expect(black_king.color).to eql(:black)
      expect(white_king).to be_instance_of(King)
      expect(white_king.color).to eql(:white)
    end

    it 'places the queen in column e' do
      black_queen = new_board[4][7]
      white_queen = new_board[4][0]
      expect(black_queen).to be_instance_of(Queen)
      expect(black_queen.color).to eql(:black)
      expect(white_queen).to be_instance_of(Queen)
      expect(white_queen.color).to eql(:white)
    end
  end
end
