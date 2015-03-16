require 'csv'

namespace :stock_management do
  #include Formatter

  task :import_export, [:file_in,:file_out] => :environment do |t,args|
    file_in = find_csv_file args[:file_in]
    file_out = args[:file_out]
    
    save_to_file convert_items(file_in), file_out

  end

  def save_to_file(records, file_out)
    f = File.open(file_out, 'w')
    f.write records.to_json
    f.close
  end

  def convert_items(file_in,file_out)
    jason_record = []
    csv_headers = %w('item id' description price cost price_type quantity_on_hand modifier_1_name modifier_1_price modifier_2_name modifier_2_price modifier_3_name modifier_3_price)
    CSV.foreach(file_in, :headers => csv_headers) do |row|
      jason_record.push convert_csv_row_to_item_json(row)
    end
  end

  def convert_csv_row_to_item_json(row)
    #item id,description,price,cost,price_type,quantity_on_hand,modifier_1_name,modifier_1_price,modifier_2_name,modifier_2_price,modifier_3_name,modifier_3_price
    { 
      item_id: row["item id"],
      description: row[:description],
      price: row[:price],
      cost: row[:cost],
      price_type: row[:price_type],
      quantity_on_hand: row[:quantity_on_hand],
      modifiers: [
        { 
          name: row[:modifier_1_name],
          price: row[:modifier_1_price]
        },{
          name: row[:modifier_2_name],
          price: row[:modifier_2_price] 
        },{
          name: row[:modifier_3_name],
          price: row[:modifier_3_price] 
        }
      ]
    }
  end

  def find_csv_file(file)
    raise "File extension must be '.csv' " unless /\.csv$/.match(file_name)
    raise "Cannot find path with inventory data" unless file.exist?
    file
  end
end

