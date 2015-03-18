require 'json'

class Exporter
  attr_accessor :export_records

  def initialize(filename, model, records)
    #take an array of hashs as input and save to file format based on the model
    raise " Missing filename to import" if (filename.nil? || filename.empty?)
    raise " Missing the record model e.g. stock_item or orders or products etc..." if (model.nil? || model.empty?)

    #verify the that the file extension desired is one that is supported
    #The extension will also set the format of the records.
    file_format = get_valid_extension(filename)    
    raise "Unknown file extension. Please try another extension." if file_format.nil?

    #verify that the model is supported
    if validate_model?(model)
      #based on the model create a hash in the structure that is necessary 
      apply_model(model, file_format, records)
    end


    #write to file
    save_to_file(filename,  @export_records)
  end
 
  def models
    { stock_item: 
      { 
        #file_format: :model_method
        json: :stock_item_json_model,
        csv: :stock_item_csv_model
      }
    }
  end 

  def formats
    [ :csv, :json ]
  end

 private
  
  def get_valid_extension(filename)
    file_name = nil
    formats.any? do |format|
      file_name = filename.match(/\.(#{format}$)/)
    end
    file_name.captures[0] unless file_name.nil? 
  end
  
  def validate_model?(model)
    models.keys.include? model.to_sym
  end

  def save_to_file(filename, records)
    f = File.open(filename, 'w')
    f.write records
    f.close
  end

  def apply_model(model, file_format, records)@export_records
    @export_records = []
    model_method = models[model.to_sym][file_format.to_sym]
    records.each do |record|
      @export_records.push self.method(model_method.to_s).call(record)
    end
  end

  def stock_item_json_model(record)
        #item id,description,price,cost,price_type,quantity_on_hand,modifier_1_name,modifier_1_price,modifier_2_name,modifier_2_price,modifier_3_name,modifier_3_price
    JSON[{ 
      id: record["item id"],
      description: record["description"],
      price: record["price"],
      cost: record["cost"],
      price_type: record["price_type"],
      quantity_on_hand: record["quantity_on_hand"],
      modifiers: [
        { 
          name: record["modifier_1_name"],
          price: record["modifier_1_price"]
        },{
          name: record["modifier_2_name"],
          price: record["modifier_2_price"] 
        },{
          name: record["modifier_3_name"],
          price: record["modifier_3_price"] 
        }
      ]
    }]
  end

  def stock_item_csv_model
    #empty
  end
end
