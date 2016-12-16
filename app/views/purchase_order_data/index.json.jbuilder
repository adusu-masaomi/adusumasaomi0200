json.array!(@purchase_order_data) do |purchase_order_datum|
  json.extract! purchase_order_datum, :id, :purchase_code, :construction_id
  json.url purchase_order_datum_url(purchase_order_datum, format: :json)
end
