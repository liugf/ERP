class AddCustomCodeToDeclaration < ActiveRecord::Migration
  def change
    add_column :declarations, :custom_code, :string
  end
end
