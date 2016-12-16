json.array!(@customer_masters) do |customer_master|
  json.extract! customer_master, :id, :customer_name, :post, :address, :tel_main, :fax_main, :email_main, :closing_date, :due_date, :responsible1, :responsible2
  json.url customer_master_url(customer_master, format: :json)
end
