class CreateTasks < ActiveRecord::Migration[7.2]
  def change
    create_table :tasks do |t|
      t.string :title, null: false
      t.text :description
      t.references :category, null: false, foreign_key: true
      t.references :commitment, null: false, foreign_key: true
      t.decimal :hours, precision: 5, scale: 2, null: false
      t.boolean :status, default: 0
      t.boolean :archived, default: 0

      t.timestamps
    end
  end
end
