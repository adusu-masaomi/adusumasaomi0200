json.extract! daily_loan_header, :id, :occurred_on, :lend, :borrow, :created_at, :updated_at
json.url daily_loan_header_url(daily_loan_header, format: :json)
