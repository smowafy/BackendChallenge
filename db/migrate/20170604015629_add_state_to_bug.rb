class AddStateToBug < ActiveRecord::Migration
  def change
    add_reference :bugs, :state, index: true
    add_foreign_key :bugs, :states
  end
end
