json.array!(@material_masters) do |material_master|
  json.extract! material_master, :id, :material_code, :material_name
  json.url material_master_url(material_master, format: :json)
end
