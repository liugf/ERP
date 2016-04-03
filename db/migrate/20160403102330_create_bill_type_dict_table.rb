class CreateBillTypeDictTable < ActiveRecord::Migration
    def change
        create_table :dict_bill_types do |t|
            t.string :code
            t.string :name
        end
    end
end
