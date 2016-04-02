class CreateTransitDeclarationTypeDictTable < ActiveRecord::Migration
    def change 
        create_table :dict_transit_declaration_types do |t|
            t.string :code
            t.string :name
        end
    end
end
