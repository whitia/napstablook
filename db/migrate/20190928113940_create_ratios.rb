class CreateRatios < ActiveRecord::Migration[5.2]
  def change
    create_table :ratios do |t|
      t.references :user, foreign_key: true
      t.string :category
      t.integer :value

      t.timestamps
    end
  end
end
