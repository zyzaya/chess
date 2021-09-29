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
  

  xit 'can be assiged a column' do
    
  end

  xit 'can be assigned a row' do
    
  end

  xit 'can have both col and row be set at the same time' do
    
  end

  xit 'changes input when settign col and row' do
    
  end

  xit 'can have input be set' do
    
  end

  xit 'changes col and row when input is set' do
    
  end
end