json.array!(@unit_masters) do |unit_master|
  json.extract! unit_master, :id, :unit_name
  json.url unit_master_url(unit_master, format: :json)
end
