json.extract! task, :id, :title, :description, :category_id, :commitment_id, :hours_allocated, :completed, :archived, :created_at, :updated_at
json.url task_url(task, format: :json)
