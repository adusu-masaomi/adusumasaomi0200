json.extract! task, :id, :construction_datum_id, :text, :start_date, :end_date, :work_start_date, :work_end_date, :duration, :parent, :progress, :sortorder, :created_at, :updated_at
json.url task_url(task, format: :json)
