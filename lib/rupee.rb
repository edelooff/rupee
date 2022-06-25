module Rupee
  # Reverse polish calculator, operating on a stream of mixed numbers and operators
  class Calculator
    attr_reader :parser, :stack

    def initialize(parser: Parser.default)
      @parser = parser
      @stack = []
    end

    def result
      stack[-1]
    end

    def <<(input_string)
      process(*@parser.tokenize(input_string))
      self
    end

    private

    def process(*tokens)
      tokens.each do |token|
        @stack.push token.is_a?(Operator) ? token.apply(@stack) : token
      end
    end
  end

  ##
  # The Parser converts input strings into a token stream of numbers and operations.
  #
  class Parser
    attr_reader :operators

    def initialize(operators)
      @operators = operators
    end

    def tokenize(input)
      # Returns a tokenized version of the string, with numbers and operators separated
      tokens = []
      number = ''
      input.each_char do |token|
        if token =~ /[\d.]/
          number += token
          next
        end
        tokens.push(to_numeric(number)) if number != ''
        tokens.push(@operators.lookup(token)) if token != ' '
        number = ''
      end
      tokens.push(to_numeric(number)) if number != ''
      tokens
    end

    # Returns a Parser with a default set of mapped Operators.
    def self.default
      operators = OperatorRegistry.new(
        {
          '+': Operator.new(:ADD, ->(a, b) { a + b }),
          '-': Operator.new(:SUB, ->(a, b) { a - b }),
          '*': Operator.new(:MUL, ->(a, b) { a * b }),
          '/': Operator.new(:DIV, ->(a, b) { a / b })
        }
      )
      Parser.new(operators)
    end

    private

    def to_numeric(string)
      if string =~ /^\d+$/
        Integer string
      else
        Float string
      end
    end
  end

  # Returns a function that can be applied to a stack, yielding a scalar result.
  class Operator
    attr_reader :name

    def initialize(name, func)
      @name = name.intern
      @func = func
    end

    def apply(stack)
      if stack.length < @func.arity
        raise ArgumentError, \
              "Not enough operands available for operation #{name}. " \
              "Require #{@func.arity} but only #{stack.length} are available."
      end

      @func.call(*stack.pop(@func.arity))
    end
  end

  # Provides a collection of Operator instances
  #
  # Operators are exported as methods based on their #name
  # The #lookup method provides a means of finding an Operator by its token
  class OperatorRegistry
    def initialize(operators)
      @lookup = {}

      operators.each do |token, operator|
        @lookup[token.intern] = operator
        if respond_to? operator.name
          raise ArgumentError, "Operator with name '#{operator.name}' already provided"
        end

        define_singleton_method(operator.name) { operator }
      end
    end

    def lookup(token)
      unregistered = !@lookup.key?(token.intern)
      raise IndexError, "No operator registered for token '#{token}'" if unregistered

      @lookup[token.intern]
    end
  end
end
