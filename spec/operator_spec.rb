require 'rupee'

describe 'Rupee::Operator' do
  context 'creation' do
    let(:name) { 'mnemonic' }
    let(:operator) { Rupee::Operator.new(name, :puts) }

    it 'name provides a short-hand representation (as symbol)' do
      expect(operator.name).to eq(name.intern)
    end
  end

  context 'application' do
    context 'consumes :arity values from the stack and returns the function result' do
      it 'given a 0-arg function, returns a static result' do
        operator = Rupee::Operator.new('NOP', -> { 'dummy' })
        stack = [:sentinel]
        expect(operator.apply(stack)).to eq('dummy')
        expect(stack).to eq([:sentinel])
      end

      it 'given a 1-arity function, consumes from the stack and returns the result' do
        operator = Rupee::Operator.new('INV', ->(n) { -n })
        stack = [10]
        expect(operator.apply(stack)).to eq(-10)
        expect(stack).to be_empty
      end

      it 'given a 2-arity function, applies stack in oldest->newest fashion' do
        operator = Rupee::Operator.new('SUB', ->(a, b) { a - b })
        stack = [10, 5]
        expect(operator.apply(stack)).to eq(5)
        expect(stack).to be_empty
      end

      it 'given a stack smaller than the function arity, raises ArgumentError' do
        operator = Rupee::Operator.new('SUB', ->(a, b) { a - b })
        stack = [10]
        expect { operator.apply(stack) }.to raise_error(
          ArgumentError, /^Not enough operands available for operation SUB/
        )
      end
    end
  end
end

describe 'Rupee::OperatorRegistry' do
  context 'given a token=>operator hash to create the registry' do
    let(:operator) { Rupee::Operator.new(:ADD, ->(a, b) { a + b }) }
    let(:registry) { Rupee::OperatorRegistry.new({ '+': operator }) }

    it 'returns the operator by token from the lookup metod' do
      expect(registry.lookup('+')).to be operator
    end

    it 'exposes the operator as public method based on its name' do
      expect(registry.ADD).to be operator
    end

    it 'raises when looking up a non-existant operator' do
      expect { registry.lookup('x') }.to raise_error(
        IndexError, /No operator registered for token 'x'/
      )
    end
  end

  context 'given two operators with the same name' do
    let(:operator) { Rupee::Operator.new(:ADD, -> { :dummy }) }
    let(:operator_hash) { { '+': operator, '$': operator } }

    it 'raises an error' do
      expect { Rupee::OperatorRegistry.new(operator_hash) }.to raise_error(
        ArgumentError, /Operator with name 'ADD' already provided/
      )
    end
  end
end
