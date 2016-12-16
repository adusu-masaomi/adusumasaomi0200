json.extract! order, :id, :purchase_order_datum_id, :material_id, :material_code, :material_name, :quantity, :created_at, :updated_at
json.url order_url(order, format: :json)