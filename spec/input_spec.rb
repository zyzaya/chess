require 'input'

class InputImplementation
  include Input
end

describe 'Input' do
  let(:input) { InputImplementation.new }
  info = 'Please enter something.'
  valid = %w[something s]
  before do
    allow(input).to receive(:gets).and_return('asdf', 5, 's')
  end

  describe '#get' do
    it 'prints info' do
      expect(input).to receive(:puts).with(info)
      input.get(info, valid)
    end

    it 'calls gets while the input is not within the given valid values' do
      expect(input).to receive(:gets).exactly(3).times
      input.get(info, valid)
    end

    it 'calls gets while the block returns false' do
      expect(input).to receive(:gets).exactly(3).times
      input.get(info) do |val|
        true if val.eql?('s')
      end
    end

    it 'does not care about case' do
      allow(input).to receive(:gets).and_return('asdf', 5, 'SOMETHING')
      expect(input).to receive(:gets).exactly(3).times
      input.get(info, valid)
    end

    it 'returns the value of gets when it is valid' do
      result = input.get(info, valid)
      expect(result).to eql('s')
    end
  end
end