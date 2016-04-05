class AddFieldToDeclaration0406 < ActiveRecord::Migration
  def change
      add_column :declarations, :allow_no, :string

      add_column :declarations, :transport_price, :decimal
      add_column :declarations, :transport_price_flag, :string
      add_column :declarations, :transport_currency, :string

      add_column :declarations, :protect_price, :decimal
      add_column :declarations, :protect_price_flag, :string
      add_column :declarations, :protect_currency, :string

      add_column :declarations, :trivial_price, :decimal
      add_column :declarations, :trivial_price_flag, :string
      add_column :declarations, :trivial_currency, :string

      remove_column :declarations, :source_or_destination_country
  end
end
