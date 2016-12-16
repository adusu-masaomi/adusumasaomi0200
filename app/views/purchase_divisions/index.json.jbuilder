json.array!(@purchase_divisions) do |purchase_division|
  json.extract! purchase_division, :id, :purchase_division_name
  json.url purchase_division_url(purchase_division, format: :json)
end
