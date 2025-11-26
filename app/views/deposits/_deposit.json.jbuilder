json.extract! deposit, :id, :invoice_header_id, :deposit_due_date, :deposit_amount, :completed_flag, :created_at, :updated_at
json.url deposit_url(deposit, format: :json)
