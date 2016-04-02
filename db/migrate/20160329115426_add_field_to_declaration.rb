class AddFieldToDeclaration < ActiveRecord::Migration
  def change
      add_column :declarations, :is_special_relationship , :boolean
      add_column :declarations, :is_price_influence, :boolean
      add_column :declarations, :is_pay_privilege, :boolean
      add_column :declarations, :check_surety, :string
      add_column :declarations, :bill_type, :string
      add_column :declarations, :trade_area, :string
      add_column :declarations, :source_or_destination_country, :string
  end
end
