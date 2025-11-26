json.extract! expence, :id, :table_id, :payment_id, :payment_method_id, :payment_on, :payment_amount, :is_completed, :created_at, :updated_at
json.url expence_url(expence, format: :json)
