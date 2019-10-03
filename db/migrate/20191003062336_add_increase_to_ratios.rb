class AddIncreaseToRatios < ActiveRecord::Migration[5.2]
  def change
    add_column :ratios, :increase, :integer
  end
end
