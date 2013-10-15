require 'active_support/core_ext/string/inflections.rb'
require_relative 'ScaffoldingField'

class ScaffoldingObject
  attr_accessor :database, :prefix, :name
  attr_reader :fields

  def initialize
    @fields = Array.new
    @template_erb_class = File.open('templates/Class.cs.erb') { |f| f.read }
    @template_erb_class_vb = File.open('templates/Class.vb.erb') { |f| f.read }
    @template_erb_sql = File.open('templates/SQL.sql.erb') { |f| f.read }
    @template_erb_webform = File.open('templates/WebForm.aspx.erb') { |f| f.read }
    @template_erb_view_edit = File.open('templates/Edit.html.cs.erb') { |f| f.read }
  end

  def add_field field
    @fields << field
  end

  def table_name
    "#{display_prefix}#{display_name}".gsub(last_word(display_name), last_word(display_name).pluralize).gsub(' ', '')
  end

  def object_name
    "#{display_name}".gsub(last_word(display_name), last_word(display_name).singularize).gsub(' ', '')
  end

  def id_name
    object_name
  end

  def display_prefix
    "#{cap @prefix}_" if @prefix
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

  def print_vb_class
    template = ERB.new @template_erb_class_vb
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
    table_name
  end

  def print_sql_sp_name_all
    "#{table_name}GetAll"
  end

  def print_sql_sp_name_load
    "#{table_name}GetByID"
  end

  def print_sql_sp_name_update
    "#{table_name}Update"
  end

  def print_sql_sp_name_save
    "#{table_name}Add"
  end

  def print_sql_sp_name_delete
    "#{table_name}Delete"
  end

  private

  def cap words
    words.split(" ").map {|word| word.capitalize}.join(" ") if (words)
  end

  def last_word words
    words.split(" ").last
  end

end
