class RenameClassColumnToFunds < ActiveRecord::Migration[5.2]
  def change
    rename_column :funds, :class, :category
  end
end
