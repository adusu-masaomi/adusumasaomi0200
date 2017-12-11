json.extract! contact, :id, :name, :company_name, :post, :address, :tel, :fax, :email, :url, :partner_division_id, :created_at, :updated_at
json.url contact_url(contact, format: :json)