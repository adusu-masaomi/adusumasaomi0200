json.array!(@supplier_masters) do |supplier_master|
  json.extract! supplier_master, :id, :supplier_name, :tel_main, :fax_main, :email_main, :responsible1, :email1, :responsible2, :email2, :responsible3, :email3
  json.url supplier_master_url(supplier_master, format: :json)
end
