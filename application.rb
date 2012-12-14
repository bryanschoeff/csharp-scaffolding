require 'FileUtils'
require 'CSV'
require 'ERB'
require_relative 'EntityFiling.rb'

RunDate = Time.new.strftime("%Y.%m.%d")
ApplicationName = "Skellington"
DatabaseName = "BryanSandbox"

ApplicationPath = "#{Dir.pwd}/"
SourcePath = "#{ApplicationPath}source/"
OutputPath = "#{ApplicationPath}output/"

filings = Array.new

def run_script filings
  load_specs filings
  print_outputs filings
end

def load_specs filings
  files = Dir.glob("#{SourcePath}*.csv")
  files.each do |file|
    next if File.directory? file
	
	file_parts = File.basename(file).gsub('.csv', '').split(' - ')
	
	filing = EntityFiling.new
	filing.entity_type = file_parts[0]
	filing.filing_type = file_parts[1]
	
    load_filing file, filing
	filings << filing
  end
end

def load_filing file, filing

  table = nil
  current_line = ''
  file_parts = File.basename(file).gsub('.csv', '').split(' - ')

  CSV.foreach(file, {:headers => :first_row}) do |line|
    if ("#{line[0]}_#{line[1]}_#{line[2]}" != current_line)
      filing.tables << table unless table.nil?
	  
      table = initialize_table filing, line
      current_line = "#{line[0]}_#{line[1]}_#{line[2]}" 
    end

    field = initialize_field line
	field.calculation_table = table.name
	
    filing.add_calculation "#{table.name}_#{line[8].gsub(' ', '')}", field if line[8] 
	table.add_calculation "#{table.name}_#{line[8].gsub(' ', '')}", field if line[8] 
    if (field.calculated)
	  table.add_calculated field
	else
	  table.add_field field
	end
	
	print "#{file} #{line}" if !(field.field)
	
  end

  filing.tables << table unless table.nil?  
end

def initialize_field line
	field = ScaffoldingField.new
	field.category = line[3]
	field.sub_category = line[4]
	field.tertiary_category = line[5]
	field.field = line[6]
    field.calculated = (line[7])
    field.field = line[7] if field.calculated
    field.db_type = 'int'
	field
end

def initialize_table filing, line
	table = ScaffoldingObject.new
	
	table.database = DatabaseName
	table.entity_type = filing.entity_type
	table.filing_type = filing.filing_type
	table.description1 = line[0]
	table.description2 = line[1]
	table.description3 = line[2]
	
	joinfield = ScaffoldingField.new
	joinfield.field = "Filing I D"
	joinfield.db_type = "int"

	table.add_field joinfield
	table
end

def print_outputs filings
  sql = ""
	
  filings.each do |filing|
	webform = ""
	mvcform = ""
	model_path = "#{OutputPath}models/#{filing.entity_type}/#{filing.filing_type}/"
	FileUtils.mkpath(model_path) if !(File.exists?(model_path) && File.directory?(model_path))
	
	filing.tables.each do |table|  	  
	  # models
	  File.open("#{model_path}#{table.name}.cs", 'w') {|f| f.write(table.print_csharp_class) }
	  
	  # views, webforms, sql
	  sql += table.print_sql_script
	  webform += table.print_webform_fields
	  #mvcform += table.print_mvcform_fields
    end
	prefix = "#{filing.entity_type}#{filing.filing_type}"
	view_path = "#{OutputPath}views/#{prefix}/"
	scripts_path = "#{OutputPath}scripts/"
	
	# main model
	File.open("#{model_path}Filing.cs", 'w') {|f| f.write(filing.print_csharp_main_class) }
	# views
	FileUtils.mkpath(view_path) if !(File.exists?(view_path) && File.directory?(view_path))
	File.open("#{view_path}Edit.cshtml", 'w') {|f| f.write(filing.print_mvcform) }
	
	# webforms  
	File.open("#{OutputPath}#{prefix}WebFormFields.aspx", 'w') {|f| f.write(webform) }

    # javascript
	FileUtils.mkpath(scripts_path) if !(File.exists?(scripts_path) && File.directory?(scripts_path))
	File.open("#{scripts_path}#{prefix}Scripts.js", 'w') {|f| f.write(filing.print_javascript) }
	
  end
  
  # sql
  File.open("#{OutputPath}SQLScript.sql", 'w') {|f| f.write(sql) }
  
end


run_script filings
