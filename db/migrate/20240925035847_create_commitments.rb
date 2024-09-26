class CreateCommitments < ActiveRecord::Migration[7.2]
  def change
    create_table :commitments do |t|
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.decimal :progress, precision: 5, scale: 2, default: 0
      t.boolean :active, default: 0

      t.timestamps
    end
  end
end
