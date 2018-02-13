json.extract! task_content, :id, :name, :created_at, :updated_at
json.url task_content_url(task_content, format: :json)
