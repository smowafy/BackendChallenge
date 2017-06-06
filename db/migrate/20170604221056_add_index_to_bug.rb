class AddIndexToBug < ActiveRecord::Migration
  def change
  		add_index :bugs, [:application_token, :number]
  end
end
