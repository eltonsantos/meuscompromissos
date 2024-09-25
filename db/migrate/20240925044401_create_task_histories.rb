class CreateTaskHistories < ActiveRecord::Migration[7.2]
  def change
    create_table :task_histories do |t|
      t.references :task, null: false, foreign_key: true
      t.references :commitment, null: false, foreign_key: true

      t.timestamps
    end
  end
end
