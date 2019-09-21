class CreateFunds < ActiveRecord::Migration[5.2]
  def change
    create_table :funds do |t|
      t.string :name
      t.string :class
      t.string :type
      t.integer :purchase
      t.integer :valuation

      t.timestamps
    end
  end
end
