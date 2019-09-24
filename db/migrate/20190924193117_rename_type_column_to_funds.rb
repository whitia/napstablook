class RenameTypeColumnToFunds < ActiveRecord::Migration[5.2]
  def change
    rename_column :funds, :type, :account
  end
end
