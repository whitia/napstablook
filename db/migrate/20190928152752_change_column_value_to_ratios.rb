class ChangeColumnValueToRatios < ActiveRecord::Migration[5.2]
  def change
    change_column :ratios, :value, :float
  end
end
