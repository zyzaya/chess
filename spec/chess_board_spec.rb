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
      0.upto(7) do |col|
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
      top_left = board[2][0]
      top_right = board[5][0]
      bottom_left = board[2][7]
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
      result = chess_board.on_board?(col: 3, row: 4)
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
    let(:piece) { instance_double('ChessPiece', instance_of?: false) }
    let(:pawn) { instance_double('ChessPiece', instance_of?: false) }
    origin = 'b1'
    dest = 'c3'
    origin_coords = { col: 1, row: 0 }
    dest_coords = { col: 2, row: 2 }
    empty_coords = { col: nil, row: nil }

    before do
      allow(chess_board).to receive(:on_board?).and_return(true)
      allow(chess_board).to receive(:to_coords).with(origin, empty_coords).and_return(origin_coords)
      allow(chess_board).to receive(:to_coords).with(dest, empty_coords).and_return(dest_coords)
      allow(chess_board).to receive(:to_coords).with(nil, origin_coords).and_return(origin_coords)
      allow(chess_board).to receive(:to_coords).with(nil, dest_coords).and_return(dest_coords)
      allow(chess_board).to receive(:move_castle).and_return(false)
      allow(chess_board).to receive(:force_move)
      allow(pawn).to receive(:instance_of?).with(Pawn).and_return(true)
    end

    it 'converts to coords format' do
      move = { origin_col: 1, origin_row: 0, dest_col: 2, dest_row: 2 }
      allow(chess_board).to receive(:piece)
      expect(chess_board).to receive(:to_coords).once.with(nil, origin_coords)
      expect(chess_board).to receive(:to_coords).with(nil, dest_coords).once
      chess_board.move_piece(**move)
    end

    it 'tries to castle' do
      expect(chess_board).to receive(:move_castle)
      chess_board.move_piece(origin, dest)
    end

    it 'tries to move a pawn' do
      expect(chess_board).to receive(:move_pawn)
      chess_board.move_piece(origin, dest)
    end

    it 'returns if it successfully castles' do
      allow(chess_board).to receive(:move_castle).and_return(true)
      expect(chess_board).not_to receive(:force_move)
      chess_board.move_piece(origin, dest)
    end

    it 'returns if it moves a pawn' do
      allow(chess_board).to receive(:move_pawn).and_return(true)
      expect(chess_board).not_to receive(:force_move)
      chess_board.move_piece(origin, dest)
    end

    it 'does nothing if origin or dest is off the board' do
      allow(chess_board).to receive(:on_board?).and_return(false)
      expect(chess_board).not_to receive(:force_move)
      chess_board.move_piece(origin, dest)
    end

    it 'calls #force_move if the move is on the board, not castling, and not a pawn' do
      expect(chess_board).to receive(:force_move)
      chess_board.move_piece(origin, dest)
    end
  end

  describe '#force_move' do
    let(:piece) { instance_double('ChessPiece', instance_of?: false) }
    origin = 'b1'
    dest = 'c3'
    origin_coords = { col: 1, row: 0 }
    dest_coords = { col: 2, row: 2 }
    empty_coords = { col: nil, row: nil }

    before do
      allow(chess_board).to receive(:to_coords).with(origin, empty_coords).and_return(origin_coords)
      allow(chess_board).to receive(:to_coords).with(dest, empty_coords).and_return(dest_coords)
      allow(chess_board).to receive(:to_coords).with(nil, origin_coords).and_return(origin_coords)
      allow(chess_board).to receive(:to_coords).with(nil, dest_coords).and_return(dest_coords)
      allow(chess_board).to receive(:piece).and_return(piece)
    end

    it 'sets dest to the piece at origin' do
      board = chess_board.instance_variable_get(:@board)
      chess_board.force_move(origin, dest)
      result = board[2][2]
      expect(result).to eql(piece)
    end

    it 'sets the piece at origin to nil' do
      board = chess_board.instance_variable_get(:@board)
      chess_board.force_move(origin, dest)
      result = board[1][0]
      expect(result).to eql(nil)
    end
  end

  describe '#to_input' do
    it 'accepts a single two character argument' do
      result = chess_board.to_input('b1')
      expect(result).not_to eql(nil)
    end

    it 'accepts named col and named row arguments' do
      result = chess_board.to_input(col: 1, row: 0)
      expect(result).not_to eql(nil)
    end

    it 'converts named col and row arguments to a two character return value' do
      result = chess_board.to_input(col: 1, row: 0)
      expect(result).to eql('b1')
    end
  end

  describe '#to_coords' do
    it 'accepts a single two character argument' do
      result = chess_board.to_coords('b1')
      expect(result).not_to eql(nil)
    end

    it 'accepts named col and named row arguments' do
      result = chess_board.to_coords(col: 1, row: 0)
      expect(result).not_to eql(nil)
    end

    it 'converts a single two character argument to a two value hash' do
      result = chess_board.to_coords('b1')
      expect(result).to eql({ col: 1, row: 0 })
    end

    it 'returns a a two character with col and row as nil when only one nil argument' do
      result = chess_board.to_coords(nil)
      expect(result).to eql({col: nil, row: nil})
    end
  end

  describe '#clone' do
    it 'creates a new objects' do
      clone = chess_board.clone
      expect(clone).not_to eql(chess_board)
      expect(clone.object_id).not_to eql(chess_board.object_id)
    end

    it 'does a deep copy of board' do
      clone = chess_board.clone
      original = []
      result = []
      0.upto(7) do |col|
        0.upto(7) do |row|
          original << chess_board.piece(col: col, row: row)
          result << clone.piece(col: col, row: row)
        end
      end
      expect(result.each_with_index.none? do |v, i|
        !v.nil? && v.equal?(original[i])
      end).to eql(true)
    end
  end

  describe '#each_cell' do
    let(:first_piece) { instance_double('ChessPiece') }
    let(:second_piece) { instance_double('ChessPiece') }

    before do
      allow(chess_board).to receive(:piece).and_return(first_piece, second_piece, nil)
    end

    it 'iterates over each cell' do
      count = 0
      chess_board.each_cell { count += 1 }
      expect(count).to eql(64)
    end

    it 'returns the piece, col, and row of each cell' do
      count = 0
      expect(chess_board).to receive(:piece).exactly(64).times
      chess_board.each_cell do |p, col, row|
        expect(p).to eql(first_piece) if count.zero?
        expect(p).to eql(second_piece) if count == 1

        expect(col).to be_a_kind_of(Integer)
        expect(row).to be_a_kind_of(Integer)
        count += 1
      end
    end
  end
end
