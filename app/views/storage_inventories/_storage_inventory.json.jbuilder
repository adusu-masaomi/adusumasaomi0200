json.extract! storage_inventory, :id, :material_master_id, :quantity, :unit_price, :created_at, :updated_at
json.url storage_inventory_url(storage_inventory, format: :json)
