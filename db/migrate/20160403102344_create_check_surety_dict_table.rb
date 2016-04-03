class CreateCheckSuretyDictTable < ActiveRecord::Migration
    def change
        create_table :dict_check_sureties do |t|
            t.string :code
            t.string :name
        end
    end
end
