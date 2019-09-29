class AddColumnIncreaseToFunds < ActiveRecord::Migration[5.2]
  def change
    add_column :funds, :increase, :integer
  end
end
