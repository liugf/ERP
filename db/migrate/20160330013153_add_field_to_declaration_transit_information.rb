class AddFieldToDeclarationTransitInformation < ActiveRecord::Migration
  def change
    add_column :declaration_transit_informations, :transit_declaration_type, :string
    add_column :declaration_transit_informations, :transit_declaration_enterprise, :string
  end
end
