class AddUserIdToTasks < ActiveRecord::Migration
  def change
    change_table :tasks do |t|
      t.integer :user_id
    end
  end
end
