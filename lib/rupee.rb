# A simply calculator
module Rupee
  def self.calc
    'Calculating ...'
  end
end

##
# Methods for converting the string input into a stream of numbers and operations
#
module Parser
  def self.tokenize(input)
    # Returns a tokenized version of the string, with numbers and operators separated
    tokens = []
    number = ''
    input.split('').each do |token|
      if token =~ /[\d.]/
        number += token
        next
      end
      tokens.push(to_numeric(number)) if number != ''
      tokens.push(TOKEN_LOOKUP[token]) if token != ' '
      number = ''
    end
    tokens.push(to_numeric(number)) if number != ''
    tokens
  end

  def self.to_numeric(string)
    if string =~ /^\d+$/
      Integer string
    else
      Float string
    end
  end

  # Returns a function that can be applied to a stack, yielding a scalar result.
  class Operator
    def initialize(token, name, func)
      @token = token
      @name = name
      @func = func
    end

    attr_reader :name, :token

    def apply(stack)
      operands = stack.pop @func.arity
      if operands.length != @func.arity
        have = operands.length
        want = @func.arity
        raise ArgumentError, "Not enough operands remain for #{name} (#{have} out of #{want})"
      end

      @func.call(*operands)
    end
  end

  OPERATORS = [
    Operator.new('+', 'ADD', ->(a, b) { a + b }),
    Operator.new('-', 'SUB', ->(a, b) { a - b }),
    Operator.new('*', 'MUL', ->(a, b) { a * b }),
    Operator.new('/', 'DIV', ->(a, b) { a / b })
  ].freeze
  TOKEN = Hash[OPERATORS.map { |oper| [oper.name, oper] }].freeze
  TOKEN_LOOKUP = Hash[OPERATORS.map { |oper| [oper.token, oper] }].freeze
end
