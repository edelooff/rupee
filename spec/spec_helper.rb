require 'rspec-parameterized'
require 'simplecov'
require 'simplecov-console'

SimpleCov.start do
  add_filter 'spec/'
  formatter SimpleCov::Formatter::Console
  enable_coverage :branch
  primary_coverage :branch
end
