# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "csv"

#資材マスターの定価を更新する

require 'date'
update_date = '2017-10-01'.to_date  #カタログの更新日とする

#日時型の場合
#require 'time'
#update_time = "2017-10-01 00:00:00 +0900"  #カタログの更新日とする
#update_time_to_time = Time.parse(update_time)

CSV.foreach('db/material_list_price_update_since_201710.csv') do |row|
 
 @material_master = MaterialMaster.where(material_code:  row[0]).first
 
 if @material_master.present?
   material_params = {list_price: row[1].to_i, list_price_update_at: update_date }
   @material_master.update(material_params)
 end 
end

#del180329
#CSV.foreach('db/contact.csv') do |row|
# Contact.create(:name => row[0], :company_name => row[1], :affiliation => row[2], :department => row[3], :post => row[4], :address => row[5], 
# :tel => row[6], :fax => row[7], :email => row[8], :url => row[9], :partner_division_id => row[10].to_i )
#end

#CSV.foreach('db/purchase.csv') do |row|
# PurchaseDatum.create(:purchase_date => row[0], :slip_code => row[1], :purchase_order_datum_id => row[2], :construction_datum_id => row[3], :material_id => row[4], :material_name => row[5], :maker_id => row[6], :maker_name => row[7], :quantity => row[8], :unit_id => row[9], :purchase_unit_price => row[10], :purchase_amount => row[11], :list_price => row[12], :purchase_id => row[13], :division_id => row[14], :supplier_id => row[15]  )
#end

#CSV.foreach('db/purchase_order.csv') do |row|
# PurchaseOrderDatum.create(:purchase_order_code => row[0], :construction_datum_id => row[1] )
#end


# CSV.foreach('db/purchase_price.csv') do |row|
# PurchaseUnitPrice.create(:supplier_id => row[0], :material_id => row[1], :supplier_material_code => row[2], :unit_price => row[3].to_i, :unit_id => row[4] )
# end


# CSV.foreach('db/material.csv') do |row|
#  MaterialMaster.create(:material_code => row[0], :material_name => row[1], :maker_id => row[2].to_i, :list_price => row[3] )
# end

# maker
# CSV.foreach('db/maker.csv') do |row|
#  MakerMaster.create(:maker_name => row[0] )
#end

#CSV.foreach('db/unit.csv') do |row|
#  UnitMaster.create(:unit_name => row[0] )
#end

#CSV.foreach('db/supplier.csv') do |row|
#  SupplierMaster.create(:supplier_name => row[0], :fax_main => row[1], :email_main => row[2], :responsible1 => row[3], :responsible2 => row[4] )
#end

#CSV.foreach('db/construction.csv') do |row|
#  ConstructionDatum.create(:construction_code => row[0], :construction_name => row[1], :reception_date => row[2], :customer_id => row[3], :construction_start_date => row[4], :construction_end_date => row[5] )
#end

#CSV.foreach('db/customer.csv') do |row|
#  CustomerMaster.create(:customer_name => row[0], :post => row[1], :address => row[2], :tel_main => row[3], :fax_main => row[4], :email_main => row[5], :closing_date => row[6].to_i, :due_date => row[7].to_i  )
#end
