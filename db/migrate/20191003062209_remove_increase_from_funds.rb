class RemoveIncreaseFromFunds < ActiveRecord::Migration[5.2]
  def change
    remove_column :funds, :increase, :integer
  end
end
