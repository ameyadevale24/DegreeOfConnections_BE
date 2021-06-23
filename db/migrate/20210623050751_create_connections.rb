class CreateConnections < ActiveRecord::Migration[6.1]
  def change
    create_table :connections do |t|
      t.integer :userid_a
      t.integer :userid_b

      t.timestamps
    end
  end
end
