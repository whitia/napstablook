class AddUserIdToFunds < ActiveRecord::Migration[5.2]
  def change
    add_reference :funds, :user, foreign_key: true
  end
end
