class CreateAppMaxBugs < ActiveRecord::Migration
  def change
    create_table :app_max_bugs do |t|
      t.integer :app_number
      t.integer :bug_number

      t.timestamps null: false
    end
  end
end
