json.extract! purchase_header, :id, :slip_code, :registration_flag, :created_at, :updated_at
json.url purchase_header_url(purchase_header, format: :json)
