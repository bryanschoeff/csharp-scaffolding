require 'FileUtils'
require 'CSV'
require 'ERB'

require_relative 'ApplicationSpec.rb'

RunDate = Time.new.strftime("%Y.%m.%d")
ApplicationName = "Skellington"
DatabaseName = "BryanSandbox"

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

  CSV.foreach(file, {:headers => :first_row}) do |line|
    if ("#{line[0]}" != current_line)
      spec.add_table table unless table.nil?
	  
      table = initialize_table line
      current_line = "#{line[0]}" 
    end

    field = initialize_field line
    table.add_field field

  end

  spec.add_table table unless table.nil?  
end

def initialize_field line
	field = ScaffoldingField.new

	field.field = line[1]
    field.db_type = line[2]
	field
end

def initialize_table line
	table = ScaffoldingObject.new
	
	table.database = DatabaseName
	table.name = line[0]
	table
end

def print_outputs spec
  sql = ""
	
  webform = ""
  mvcform = ""
  model_path = "#{OutputPath}models/"
  view_path = "#{OutputPath}views/"

  FileUtils.mkpath(model_path) if !(File.exists?(model_path) && File.directory?(model_path))
	
  spec.tables.each do |table|  	  
    # models
    File.open("#{model_path}#{table.object_name}.cs", 'w') {|f| f.write(table.print_csharp_class) }
    
    # views, webforms, sql
    sql += table.print_sql_script
    webform += table.print_webform_fields

    # views
	FileUtils.mkpath(view_path) if !(File.exists?(view_path) && File.directory?(view_path))
	File.open("#{view_path}Edit.cshtml", 'w') {|f| f.write(table.print_mvc_form) }

    # webforms  
	File.open("#{OutputPath}#{table.object_name}Edit.aspx", 'w') {|f| f.write(webform) }

  end
  scripts_path = "#{OutputPath}scripts/"
 
  # sql
  File.open("#{OutputPath}SQLScript.sql", 'w') {|f| f.write(sql) }
  
end


run_script spec
