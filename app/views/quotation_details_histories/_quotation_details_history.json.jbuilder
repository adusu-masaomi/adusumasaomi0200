json.extract! quotation_details_history, :id, :quotation_header_history_id, :quotation_breakdown_history_id, :working_middle_item_id, :working_middle_item_name, :working_middle_item_short_name, :line_number, :working_middle_specification, :quantity, :execution_quontity, :working_unit_id, :working_unit_price, :quote_price, :execution_unit_price, :execution_price, :labor_productivity_unit, :labor_productivity_unit_total, :remarks, :construction_type, :piping_wiring_flag, :equipment_mounting_flag, :labor_cost_flag, :created_at, :updated_at
json.url quotation_details_history_url(quotation_details_history, format: :json)