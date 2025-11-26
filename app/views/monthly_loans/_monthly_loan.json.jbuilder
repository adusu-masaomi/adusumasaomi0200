json.extract! monthly_loan, :id, :occur_year_month, :lend, :borrow, :is_actual, :created_at, :updated_at
json.url monthly_loan_url(monthly_loan, format: :json)
