require_relative 'ScaffoldingField'

class ScaffoldingObject
  attr_accessor :database, :name, :fields

  def initialize
    @fields = Array.new
    
    @template_erb_class = File.open('templates/Class.cs.erb') { |f| f.read }
    @template_erb_sql = File.open('templates/SQL.sql.erb') { |f| f.read }
    @template_erb_webform = File.open('templates/WebForm.aspx.erb') { |f| f.read }
    @template_erb_view_edit = File.open('templates/Edit.html.cs.erb') { |f| f.read }
    #@template_erb_view_index = File.open('templates/Index.cs.erb') { |f| f.read }
  end

  def add_field field
    @fields << field
  end

  def object_name
	"#{display_name}".gsub(' ', '')
  end
  
  def display_name
	"#{cap name}"
  end

  def print_sql_script
    template = ERB.new @template_erb_sql
    template.result(binding)
  end

  def print_csharp_class
    template = ERB.new @template_erb_class
    template.result(binding)
  end

  def print_mvc_form
    template = ERB.new @template_erb_view_edit
    template.result(binding)
  end

  def print_webform_fields
    template = ERB.new @template_erb_webform
    template.result(binding)
  end

  def print_sql_table_name
    "#{object_name}"
  end

  def print_sql_sp_name_load
    "#{object_name}GetByID"
  end
 
  def print_sql_sp_name_update
    "#{object_name}Update"
  end

  def print_sql_sp_name_save
    "#{object_name}Add"
  end
 
  def print_sql_sp_name_delete
    "#{object_name}Delete"
  end

  def cap words
	words.split(" ").map {|words| words.capitalize}.join(" ") if (words)
  end
 
end
