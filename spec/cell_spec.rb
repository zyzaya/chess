# frozen_string_literal: true

require 'cell'

describe Cell do
  let(:cell) { Cell.new('a1') }

  describe '#initialize' do
    it 'accepts a string initial value' do
      cell = Cell.new('a1')
      expect(cell.input).to eql('a1')
      expect(cell.col).to eql(0)
      expect(cell.row).to eql(0)
    end

    it 'accepts a hash containing col and row initial value' do
      cell = Cell.new(col: 0, row: 0)
      expect(cell.input).to eql('a1')
      expect(cell.col).to eql(0)
      expect(cell.row).to eql(0)
    end
  end

  it 'can be assiged a column' do
    val = 1
    cell.col = val
    expect(cell.col).to eql(val)
  end

  it 'can be assigned a row' do
    val = 1
    cell.row = val
    expect(cell.row).to eql(val)
  end

  it 'can have both col and row be set at the same time' do
    col = 1
    row = 2
    cell.coords(col, row)
    expect(cell.col).to eql(col)
    expect(cell.row).to eql(row)
  end

  it 'changes input when settign col and row' do
    col = 1
    row = 2
    cell.coords(col, row)
    expect(cell.input).to eql('b3')
  end

  it 'can have input be set' do
    val = 'b3'
    cell.input = val
    expect(cell.input).to eql(val)
  end

  it 'changes col and row when input is set' do
    val = 'b3'
    cell.input = val
    expect(cell.col).to eql(1)
    expect(cell.row).to eql(2)
  end

  it 'defines == as the col and rows being the same' do
    cell2 = Cell.new(col: cell.col, row: cell.row)
    result = cell == cell2
    expect(result).to eql(true)
  end

  describe '#adjacent' do
    it 'does not change the row when argument is left or right' do
      result = cell.adjacent(:left)
      expect(result.row).to eql(cell.row)
    end

    it 'does not change the column when argument is up or down' do
      result = cell.adjacent(:up)
      expect(result.col).to eql(cell.col)
    end

    it 'adds one to the row if the side is up' do
      result = cell.adjacent(:up)
      expect(result.row).to eql(cell.row + 1)
    end

    it 'subtracts one from the row if the side is down' do
      result = cell.adjacent(:down)
      expect(result.row).to eql(cell.row - 1)
    end

    it 'adds one to the column if the side is right' do
      result = cell.adjacent(:right)
      expect(result.col).to eql(cell.col + 1)
    end

    it 'subtracts one from the column if the side is left' do
      result = cell.adjacent(:left)
      expect(result.col).to eql(cell.col - 1)
    end
  end
end
