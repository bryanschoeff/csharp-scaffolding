require_relative 'ScaffoldingObject'

class ApplicationSpec
  attr_accessor :name, :tables

  def initialize
    @tables = Array.new
  end

  def add_calculation calculation, field
    @calculations[calculation] = Array.new unless @calculations[calculation]
    @calculations[calculation] << field
  end

end
