require 'rupee'

describe 'Parser::tokenize' do
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
      expect(Parser.tokenize('12 5+')).to eq([12, 5, Parser::OPERATOR.ADD])
    end
  end
end

describe 'Parser::Operator' do
  context 'creation' do
    let(:name) { 'mnemonic' }
    let(:operator) { Parser::Operator.new(name, :puts) }

    it 'name provides a short-hand representation (as symbol)' do
      expect(operator.name).to eq(name.intern)
    end
  end

  context 'application' do
    context 'consumes :arity values from the stack and returns the function result' do
      it 'given a 0-arg function, returns a static result' do
        operator = Parser::Operator.new('NOP', -> { 'dummy' })
        stack = ['sentinel']
        expect(operator.apply(stack)).to eq('dummy')
        expect(stack).to eq(['sentinel'])
      end

      it 'given a 1-arity function, consumes from the stack and returns the result' do
        operator = Parser::Operator.new('INV', ->(n) { -n })
        stack = [10]
        expect(operator.apply(stack)).to eq(-10)
        expect(stack).to be_empty
      end

      it 'given a 2-arity function, applies stack in oldest->newest fashion' do
        operator = Parser::Operator.new('SUB', ->(a, b) { a - b })
        stack = [10, 5]
        expect(operator.apply(stack)).to eq(5)
        expect(stack).to be_empty
      end

      it 'given a stack smaller than the function arity, raises ArgumentError' do
        operator = Parser::Operator.new('SUB', ->(a, b) { a - b })
        stack = [10]
        expect { operator.apply(stack) }.to raise_error(
          ArgumentError, /^Not enough operands available for operation SUB/
        )
      end
    end
  end
end

describe 'Parser::OPERATOR' do
  context '+ addition' do
    it 'given a stack [sentinel, 12, 13]' do
      stack = ['sentinel', 12, 13]
      expect(Parser::OPERATOR.ADD.apply(stack)).to eq(25)
      expect(stack).to eq(['sentinel'])
    end
  end
  context '- subtraction' do
    it 'given a stack [sentinel, 100, 58]' do
      stack = ['sentinel', 100, 58]
      expect(Parser::OPERATOR.SUB.apply(stack)).to eq(42)
      expect(stack).to eq(['sentinel'])
    end
  end
  context '* multiplication' do
    it 'given a stack [sentinel, 6, 7]' do
      stack = ['sentinel', 6, 7]
      expect(Parser::OPERATOR.MUL.apply(stack)).to eq(42)
      expect(stack).to eq(['sentinel'])
    end
  end
  context '/ division' do
    it 'given a stack [sentinel, 42, 6]' do
      stack = ['sentinel', 42, 6]
      expect(Parser::OPERATOR.DIV.apply(stack)).to eq(7)
      expect(stack).to eq(['sentinel'])
    end
  end
end
