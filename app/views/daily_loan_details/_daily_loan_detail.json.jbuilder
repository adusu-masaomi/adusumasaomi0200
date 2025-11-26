json.extract! daily_loan_detail, :id, :table_type_id, :table_id, :lend_borrow_id, :occurred_on, :summary, :amount, :source_id, :created_at, :updated_at
json.url daily_loan_detail_url(daily_loan_detail, format: :json)
