require_relative 'ScaffoldingObject'

class ApplicationSpec
  attr_accessor :name, :tables

  def initialize
    @tables = Array.new
  end

  def add_table table
    @tables << table
  end

end
