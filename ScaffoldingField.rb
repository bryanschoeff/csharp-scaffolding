class ScaffoldingField
  attr_accessor :field, :db_type

  def initialize
  end

  def csharp_type
    if @db_type.include? 'decimal'
      "decimal"
    elsif @db_type.include? 'varchar'
      "string"
    elsif @db_type.include? 'int'
      "int"
    elsif @db_type.include? 'bit'
      "bool"
    else
      "string"
    end

  end
 
  def name
    display_name.gsub(' ','')
  end

  def sql_parameter
    "@#{name}"
  end

  def display_name
    cap @field
  end
  
  def csharp_name
    name
  end

  def sql_column
    "[#{name}]"
  end

  def sql_column_name
	name
  end

  def calculated_name
    field.gsub(' ', '')
  end
  
  def webform_textbox
    "txt#{csharp_name}"
  end

  def view_field_id
    name
  end

  def cap words
	words.split(" ").map {|words| words.capitalize}.join(" ") if (words)
  end
  
end
