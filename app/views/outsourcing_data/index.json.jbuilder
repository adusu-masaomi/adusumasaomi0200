json.array!(@purchase_data) do |purchase_datum|
  json.extract! purchase_datum, :id, :purchase_date, :order_number, :material_code, :material_name, :maker_id, :maker_name, :quantity, :unit, :purchase_unit_price, :purchase_amount, :list_price, :supplier_id, :division_id
  json.url purchase_datum_url(purchase_datum, format: :json)
end
