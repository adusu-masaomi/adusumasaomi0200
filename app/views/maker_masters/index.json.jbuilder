json.array!(@maker_masters) do |maker_master|
  json.extract! maker_master, :id, :maker_name
  json.url maker_master_url(maker_master, format: :json)
end
