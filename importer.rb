require 'csv'

class Importer
  attr_accessor :records

  #need to instantiate the class because we want an instance to only be able to work on one file at atime.
  def initialize (filename = nil)
    raise " Missing filename to import" if (filename.nil? || filename.empty?)
    import(filename)
  end 

  def formats
    { csv: :import_CSV_file }
  end

  private

  def import(filename)
    #check the file extension and return the file format to use
    file_format = valid_extension(filename)

    #check the model, default to stock_item
    if validate_format?(file_format)
      #use the file format
      import_method = formats[file_format.to_sym]
      self.method(import_method.to_s).call(filename) 
    end
  end

  def valid_extension(filename)
    #this is where new file and type formats are added.
    if /\.csv$/.match(filename)
      "csv"
    else
      raise "Unknown file extension. Please try another extension or add it to this list:
      *.csv
      "
    end
  end

  def validate_format?(file_format)
    valid_formats = formats.keys
    return formats.keys.include? file_format.to_sym
  end

  def import_CSV_file(filename)
    @records = []
    raise "no file found " unless File.exist?(filename)
    CSV.foreach(filename, :headers => true) do |row|
      @records.push row
    end
  end
end

def imported_records(filename)
  importer = Importer.new(filename)
  importer.records
end
