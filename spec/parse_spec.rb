require 'rupee'

describe 'tokenize' do
  context 'given an empty string' do
    it 'returns an empty array of tokens' do
      expect(Parser.tokenize('')).to eq([])
    end
  end

  context 'given single numbers' do
    it 'given 5' do
      expect(Parser.tokenize('5')).to eq([5])
    end
    it 'given 42' do
      expect(Parser.tokenize('42')).to eq([42])
    end
    it 'given 12.34' do
      expect(Parser.tokenize('12.34')).to eq([12.34])
    end
  end

  context 'given multiple numbers' do
    it 'given 1 2 4 8' do
      expect(Parser.tokenize('1 2 4 8')).to eq([1, 2, 4, 8])
    end
    it 'given 1002 2001' do
      expect(Parser.tokenize('1002 2001')).to eq([1002, 2001])
    end
    it 'given 0.017 0.39' do
      expect(Parser.tokenize('0.017 0.39')).to eq([0.017, 0.39])
    end
  end

  context 'given mix of numbers and tokens' do
    it 'given 12 5+' do
      expect(Parser.tokenize('12 5+')).to eq([12, 5, Parser::TOKEN['ADD']])
    end
  end
end

describe 'Parser::TOKEN' do
  context '+ addition' do
    it 'given a stack [sentinel, 12, 13]' do
      stack = ['sentinel', 12, 13]
      expect(Parser::TOKEN['ADD'].apply(stack)).to eq(25)
      expect(stack).to eq(['sentinel'])
    end
  end
  context '- subtraction' do
    it 'given a stack [sentinel, 100, 58]' do
      stack = ['sentinel', 100, 58]
      expect(Parser::TOKEN['SUB'].apply(stack)).to eq(42)
      expect(stack).to eq(['sentinel'])
    end
  end
  context '* multiplication' do
    it 'given a stack [sentinel, 6, 7]' do
      stack = ['sentinel', 6, 7]
      expect(Parser::TOKEN['MUL'].apply(stack)).to eq(42)
      expect(stack).to eq(['sentinel'])
    end
  end
  context '/ division' do
    it 'given a stack [sentinel, 42, 6]' do
      stack = ['sentinel', 42, 6]
      expect(Parser::TOKEN['DIV'].apply(stack)).to eq(7)
      expect(stack).to eq(['sentinel'])
    end
  end
end
