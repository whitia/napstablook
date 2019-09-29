class AddColumnDifferenceToFunds < ActiveRecord::Migration[5.2]
  def change
    add_column :funds, :difference, :integer
  end
end
