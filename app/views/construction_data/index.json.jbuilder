json.array!(@construction_data) do |construction_datum|
  json.extract! construction_datum, :id, :construction_code, :construction_name, :reception_date, :customer_id, :construction_start_date, :construction_end_date
  json.url construction_datum_url(construction_datum, format: :json)
end
