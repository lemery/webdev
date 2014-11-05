class Task < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.string :description
      t.string :due
    end
  end
end
