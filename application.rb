require 'fileutils'
require 'csv'
require 'erb'

require_relative 'ApplicationSpec.rb'

RunDate = Time.new.strftime("%Y.%m.%d")
ApplicationName = "YearEnd"
DatabaseName = "WebUAN"

ApplicationPath = "#{Dir.pwd}/"
SourcePath = "#{ApplicationPath}source/"
OutputPath = "#{ApplicationPath}output/"

spec = ApplicationSpec.new

def run_script spec
  load_specs spec
  print_outputs spec
end

def load_specs spec

  files = Dir.glob("#{SourcePath}*.csv")
  files.each do |file|
    next if File.directory? file
	
    load_file file, spec
  end
end

def load_file file, spec

  table = nil
  current_line = ''

  CSV.foreach(file, {encoding: "iso-8859-1:UTF-8", :headers => :first_row}) do |line|
    if ("#{line[0]}#{line[1]}" != current_line)
      spec.add_table table unless table.nil?
	  
      table = initialize_table line
      current_line = "#{line[0]}#{line[1]}" 
    end

    field = initialize_field line
    table.add_field field

  end

  spec.add_table table unless table.nil?  
end

def initialize_field line
	field = ScaffoldingField.new

	field.field = line[2]
    field.db_type = line[3]
	field
end

def initialize_table line
	table = ScaffoldingObject.new
	
	table.database = DatabaseName
	table.prefix = line[0]
	table.name = line[1]
	table
end

def print_outputs spec
  sql = ""
	
  webform = ""
  model_path = "#{OutputPath}models/"
  view_path = "#{OutputPath}views/"

  FileUtils.mkpath(model_path) if !(File.exists?(model_path) && File.directory?(model_path))
  FileUtils.mkpath(view_path) if !(File.exists?(view_path) && File.directory?(view_path))	

  spec.tables.each do |table|  	  
    # models
    File.open("#{model_path}#{table.object_name}.cs", 'w') {|f| f.write(table.print_csharp_class) }
    File.open("#{model_path}#{table.object_name}.vb", 'w') {|f| f.write(table.print_vb_class) }
	
    # views, webforms, sql
    sql += table.print_sql_script
    webform += table.print_webform_fields

    # views
    FileUtils.mkpath("#{view_path}#{table.object_name}") if !(File.exists?("#{view_path}#{table.object_name}") && File.directory?("#{view_path}#{table.object_name}"))	
	File.open("#{view_path}#{table.object_name}/Edit.cshtml", 'w') {|f| f.write(table.print_mvc_form) }

    # webforms  
	File.open("#{OutputPath}#{table.object_name}Edit.aspx", 'w') {|f| f.write(webform) }

  end
  # sql
  File.open("#{OutputPath}SQLScript.sql", 'w') {|f| f.write(sql) }
  
end


run_script spec
