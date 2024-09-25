class CreateCommitments < ActiveRecord::Migration[7.2]
  def change
    create_table :commitments do |t|
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.integer :progress

      t.timestamps
    end
  end
end
