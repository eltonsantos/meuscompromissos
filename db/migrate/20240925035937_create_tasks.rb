class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :title
      t.text :description
      t.references :category, null: false, foreign_key: true
      t.references :commitment, null: false, foreign_key: true
      t.integer :hours_allocated
      t.boolean :completed
      t.boolean :archived

      t.timestamps
    end
  end
end
