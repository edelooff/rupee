require 'rupee'

describe 'Parser::tokenize' do
  let(:parser) { Rupee::Parser.default }

  context 'given an empty string' do
    it 'returns an empty array of tokens' do
      expect(parser.tokenize('')).to eq([])
    end
  end

  context 'given single numbers' do
    it 'given 5' do
      expect(parser.tokenize('5')).to eq([5])
    end
    it 'given 42' do
      expect(parser.tokenize('42')).to eq([42])
    end
    it 'given 12.34' do
      expect(parser.tokenize('12.34')).to eq([12.34])
    end
  end

  context 'given multiple numbers' do
    it 'given 1 2 4 8' do
      expect(parser.tokenize('1 2 4 8')).to eq([1, 2, 4, 8])
    end
    it 'given 1002 2001' do
      expect(parser.tokenize('1002 2001')).to eq([1002, 2001])
    end
    it 'given 0.017 0.39' do
      expect(parser.tokenize('0.017 0.39')).to eq([0.017, 0.39])
    end
  end

  context 'given mix of numbers and tokens' do
    it 'given 12 5+' do
      expect(parser.tokenize('12 5+')).to eq([12, 5, parser.operators.ADD])
    end
  end
end
