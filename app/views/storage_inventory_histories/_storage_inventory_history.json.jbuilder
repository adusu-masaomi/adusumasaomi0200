json.extract! storage_inventory_history, :id, :occurred_date, :slip_code, :purchase_order_datum_id, :construction_datum_id, :material_master_id, :quantity, :unit_price, :amount, :supplier_master_id, :invenrtory_division_id, :created_at, :updated_at
json.url storage_inventory_history_url(storage_inventory_history, format: :json)
