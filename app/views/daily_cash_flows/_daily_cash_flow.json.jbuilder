json.extract! daily_cash_flow, :id, :cash_flow_date, :income, :expence, :balance, :plan_actual_flag, :completed_flag, :created_at, :updated_at
json.url daily_cash_flow_url(daily_cash_flow, format: :json)
