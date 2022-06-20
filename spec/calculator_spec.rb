require 'rupee'

describe 'Calculator' do
  let(:calculator) { Rupee::Calculator.new }

  context 'given a new calculator' do
    it 'initial result is nil' do
      expect(calculator.result).to be_nil
    end
    it 'initial stack is empty' do
      expect(calculator.stack).to be_empty
    end
  end

  context 'given an empty instruction string' do
    it 'result remains nil' do
      calculator << ''
      expect(calculator.result).to be_nil
    end
    it 'stack remains empty' do
      calculator << ''
      expect(calculator.stack).to be_empty
    end
  end

  context 'given an instruction string of several numbers' do
    it 'result is the last number in the token set' do
      calculator << '30 12'
      expect(calculator.result).to eq 12
    end
    it 'stack contains numbers in given order' do
      calculator << '30 12'
      expect(calculator.stack).to eq [30, 12]
    end
  end

  context 'given several numbers and an operation' do
    it "result provides the operation's return value" do
      calculator << '30 12+'
      expect(calculator.result).to eq 42
    end

    it 'stack contains the outcome of the operation' do
      calculator << '30 12+'
      expect(calculator.stack).to eq [42]
    end

    it 'stack contains any leftover numbers' do
      calculator << '1 2 3 4 5+'
      expect(calculator.stack).to eq [1, 2, 3, 9]
    end
  end

  context 'operator whitespace separation' do
    it 'is not required' do
      calculator << '2 3+5+'
      expect(calculator.result).to eq 10
    end

    it 'but is permitted' do
      calculator << '2 3 + 5 +'
      expect(calculator.result).to eq 10
    end
  end

  context 'given various token sequences' do
    where do
      {
        'addition: 30 + 12' => { instruction: '30 12+', result: 42 },
        'repeated addition: 2 + 3 + 5' => { instruction: '2 3 5++', result: 10 },
        'subtraction: 8 - 50' => { instruction: '8 50-', result: -42 },
        'multiplication: 6 * 7' => { instruction: '6 7*', result: 42 },
        'division: 42 / 6' => { instruction: '42 6 /', result: 7 },
        'mixed-operator: 2 + (3 * 4)' => { instruction: '2 3 4 * +', result: 14 },
        'mixed-operator: (2 + 3) * 4' => { instruction: '2 3 + 4 *', result: 20 }
      }
    end

    with_them do
      it "result correctly returns #{params[:result]}" do
        calculator << instruction
        expect(calculator.result).to eq result
      end
    end
  end
end
