# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170710044738) do

  create_table "affiliations", force: :cascade do |t|
    t.string   "affiliation_name", limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "update_at",                    null: false
  end

  create_table "attendance_name_master", force: :cascade do |t|
    t.string   "name",     limit: 8
    t.datetime "created"
    t.datetime "modified"
  end

  create_table "business_holidays", force: :cascade do |t|
    t.date     "working_date"
    t.integer  "holiday_flag", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "construction_costs", force: :cascade do |t|
    t.integer  "construction_datum_id", limit: 4
    t.integer  "purchase_amount",       limit: 4
    t.integer  "supplies_expense",      limit: 4
    t.integer  "labor_cost",            limit: 4
    t.integer  "misellaneous_expense",  limit: 4
    t.integer  "execution_amount",      limit: 4
    t.integer  "constructing_amount",   limit: 4
    t.string   "purchase_order_amount", limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "update_at",                         null: false
  end

  create_table "construction_daily_reports", force: :cascade do |t|
    t.date     "working_date"
    t.integer  "construction_datum_id", limit: 4
    t.integer  "staff_id",              limit: 4
    t.time     "start_time_1"
    t.time     "end_time_1"
    t.time     "start_time_2"
    t.time     "end_time_2"
    t.integer  "working_times",         limit: 4
    t.decimal  "man_month",                         precision: 6, scale: 3
    t.integer  "labor_cost",            limit: 4
    t.string   "working_details",       limit: 255
    t.datetime "created_at",                                                null: false
    t.datetime "update_at",                                                 null: false
  end

  add_index "construction_daily_reports", ["construction_datum_id", "working_date", "staff_id", "start_time_1", "end_time_1"], name: "idx_staff_working_hours", unique: true, using: :btree

  create_table "construction_data", force: :cascade do |t|
    t.string   "construction_code",          limit: 255
    t.string   "construction_name",          limit: 255
    t.string   "alias_name",                 limit: 255
    t.date     "reception_date"
    t.integer  "customer_id",                limit: 4
    t.date     "construction_start_date"
    t.date     "construction_end_date"
    t.date     "construction_period_start"
    t.date     "construction_period_end"
    t.string   "post",                       limit: 255
    t.string   "address",                    limit: 255
    t.string   "address2",                   limit: 255
    t.decimal  "latitude",                               precision: 9, scale: 6
    t.decimal  "longitude",                              precision: 9, scale: 6
    t.string   "construction_detail",        limit: 255
    t.string   "attention_matter",           limit: 255
    t.integer  "working_safety_matter_id",   limit: 4
    t.string   "working_safety_matter_name", limit: 255
    t.integer  "billed_flag",                limit: 4
    t.datetime "created_at",                                                     null: false
    t.datetime "update_at",                                                      null: false
  end

  create_table "contacts", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "search_character",    limit: 255
    t.string   "company_name",        limit: 255
    t.string   "affiliation",         limit: 255
    t.string   "department",          limit: 255
    t.string   "post",                limit: 255
    t.string   "address",             limit: 255
    t.string   "tel",                 limit: 255
    t.string   "fax",                 limit: 255
    t.string   "email",               limit: 255
    t.string   "url",                 limit: 255
    t.integer  "partner_division_id", limit: 4,   default: 0
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "customer_masters", force: :cascade do |t|
    t.string   "customer_name",    limit: 255
    t.string   "search_character", limit: 255
    t.string   "post",             limit: 255
    t.string   "address",          limit: 255
    t.string   "tel_main",         limit: 255
    t.string   "fax_main",         limit: 255
    t.string   "email_main",       limit: 255
    t.integer  "closing_date",     limit: 4
    t.integer  "due_date",         limit: 4
    t.integer  "honorific_id",     limit: 4
    t.string   "responsible1",     limit: 255
    t.string   "responsible2",     limit: 255
    t.integer  "contact_id",       limit: 4
    t.datetime "created_at",                   null: false
    t.datetime "update_at",                    null: false
  end

  create_table "delivery_slip_detail_large_classifications", force: :cascade do |t|
    t.integer  "delivery_slip_header_id",         limit: 4
    t.integer  "delivery_slip_items_division_id", limit: 4
    t.integer  "working_large_item_id",           limit: 4
    t.string   "working_large_item_name",         limit: 255
    t.string   "working_large_item_short_name",   limit: 255
    t.string   "working_large_specification",     limit: 255
    t.integer  "line_number",                     limit: 4
    t.integer  "quantity",                        limit: 4
    t.integer  "execution_quantity",              limit: 4
    t.integer  "working_unit_id",                 limit: 4
    t.string   "working_unit_name",               limit: 255
    t.integer  "working_unit_price",              limit: 4
    t.string   "delivery_slip_price",             limit: 255
    t.integer  "execution_unit_price",            limit: 4
    t.string   "execution_price",                 limit: 255
    t.float    "labor_productivity_unit",         limit: 24
    t.float    "labor_productivity_unit_total",   limit: 24
    t.integer  "last_line_number",                limit: 4
    t.string   "remarks",                         limit: 255
    t.integer  "construction_type",               limit: 4
    t.integer  "piping_wiring_flag",              limit: 4
    t.integer  "equipment_mounting_flag",         limit: 4
    t.integer  "labor_cost_flag",                 limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "delivery_slip_detail_middle_classifications", force: :cascade do |t|
    t.integer  "delivery_slip_header_id",                      limit: 4
    t.integer  "delivery_slip_detail_large_classification_id", limit: 4
    t.integer  "delivery_slip_item_division_id",               limit: 4
    t.integer  "working_middle_item_id",                       limit: 4
    t.string   "working_middle_item_name",                     limit: 255
    t.string   "working_middle_item_short_name",               limit: 255
    t.integer  "line_number",                                  limit: 4
    t.string   "working_middle_specification",                 limit: 255
    t.integer  "quantity",                                     limit: 4
    t.integer  "execution_quantity",                           limit: 4
    t.integer  "working_unit_id",                              limit: 4
    t.string   "working_unit_name",                            limit: 255
    t.integer  "working_unit_price",                           limit: 4
    t.string   "delivery_slip_price",                          limit: 255
    t.integer  "execution_unit_price",                         limit: 4
    t.string   "execution_price",                              limit: 255
    t.integer  "material_id",                                  limit: 4
    t.string   "working_material_name",                        limit: 255
    t.integer  "material_unit_price",                          limit: 4
    t.float    "labor_unit_price",                             limit: 24
    t.float    "labor_productivity_unit",                      limit: 24
    t.float    "labor_productivity_unit_total",                limit: 24
    t.integer  "material_quantity",                            limit: 4
    t.integer  "accessory_cost",                               limit: 4
    t.integer  "material_cost_total",                          limit: 4
    t.integer  "labor_cost_total",                             limit: 4
    t.integer  "other_cost",                                   limit: 4
    t.string   "remarks",                                      limit: 255
    t.integer  "construction_type",                            limit: 4
    t.integer  "piping_wiring_flag",                           limit: 4
    t.integer  "equipment_mounting_flag",                      limit: 4
    t.integer  "labor_cost_flag",                              limit: 4
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
  end

  create_table "delivery_slip_headers", force: :cascade do |t|
    t.string   "delivery_slip_code",    limit: 255
    t.string   "quotation_code",        limit: 255
    t.string   "invoice_code",          limit: 255
    t.date     "delivery_slip_date"
    t.integer  "construction_datum_id", limit: 4
    t.string   "construction_name",     limit: 255
    t.integer  "customer_id",           limit: 4
    t.string   "customer_name",         limit: 255
    t.integer  "honorific_id",          limit: 4
    t.string   "responsible1",          limit: 255
    t.string   "responsible2",          limit: 255
    t.string   "post",                  limit: 255
    t.string   "address",               limit: 255
    t.string   "tel",                   limit: 255
    t.string   "fax",                   limit: 255
    t.string   "construction_period",   limit: 255
    t.string   "construction_place",    limit: 255
    t.integer  "delivery_amount",       limit: 4
    t.integer  "execution_amount",      limit: 4
    t.integer  "last_line_number",      limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "employee_master", force: :cascade do |t|
    t.string   "name",             limit: 18
    t.string   "furigana",         limit: 18
    t.string   "affiliation_code", limit: 2
    t.integer  "hourly_wage",      limit: 4
    t.integer  "dayly_pay",        limit: 4
    t.datetime "created"
    t.datetime "modified"
  end

  create_table "inventories", force: :cascade do |t|
    t.integer  "warehouse_id",             limit: 4
    t.integer  "location_id",              limit: 4
    t.integer  "material_master_id",       limit: 4
    t.integer  "inventory_quantity",       limit: 4
    t.integer  "unit_master_id",           limit: 4
    t.integer  "inventory_amount",         limit: 4
    t.integer  "supplier_master_id",       limit: 4
    t.integer  "current_history_id",       limit: 4
    t.date     "current_warehousing_date"
    t.integer  "current_quantity",         limit: 4
    t.float    "current_unit_price",       limit: 24
    t.date     "last_warehousing_date"
    t.float    "last_unit_price",          limit: 24
    t.integer  "next_history_id_1",        limit: 4
    t.date     "next_warehousing_date_1"
    t.integer  "next_quantity_1",          limit: 4
    t.float    "next_unit_price_1",        limit: 24
    t.integer  "next_history_id_2",        limit: 4
    t.date     "next_warehousing_date_2"
    t.integer  "next_quantity_2",          limit: 4
    t.float    "next_unit_price_2",        limit: 24
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "inventory_histories", force: :cascade do |t|
    t.date     "inventory_date"
    t.integer  "inventory_division_id", limit: 4
    t.integer  "construction_datum_id", limit: 4
    t.integer  "material_master_id",    limit: 4
    t.integer  "quantity",              limit: 4
    t.integer  "inventory_quantity",    limit: 4
    t.integer  "unit_master_id",        limit: 4
    t.float    "unit_price",            limit: 24
    t.integer  "price",                 limit: 4
    t.integer  "supplier_master_id",    limit: 4
    t.string   "slip_code",             limit: 255
    t.integer  "purchase_datum_id",     limit: 4
    t.integer  "previous_quantity",     limit: 4
    t.float    "previous_unit_price",   limit: 24
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "invoice_detail_large_classifications", force: :cascade do |t|
    t.integer  "invoice_header_id",             limit: 4
    t.integer  "invoice_items_division_id",     limit: 4
    t.integer  "working_large_item_id",         limit: 4
    t.string   "working_large_item_name",       limit: 255
    t.string   "working_large_item_short_name", limit: 255
    t.string   "working_large_specification",   limit: 255
    t.integer  "line_number",                   limit: 4
    t.integer  "quantity",                      limit: 4
    t.integer  "execution_quantity",            limit: 4
    t.integer  "working_unit_id",               limit: 4
    t.string   "working_unit_name",             limit: 255
    t.integer  "working_unit_price",            limit: 4
    t.string   "invoice_price",                 limit: 255
    t.integer  "execution_unit_price",          limit: 4
    t.string   "execution_price",               limit: 255
    t.float    "labor_productivity_unit",       limit: 24
    t.float    "labor_productivity_unit_total", limit: 24
    t.integer  "last_line_number",              limit: 4
    t.string   "remarks",                       limit: 255
    t.integer  "delivery_slip_header_id",       limit: 4
    t.integer  "construction_type",             limit: 4
    t.integer  "piping_wiring_flag",            limit: 4
    t.integer  "equipment_mounting_flag",       limit: 4
    t.integer  "labor_cost_flag",               limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "invoice_detail_middle_classifications", force: :cascade do |t|
    t.integer  "invoice_header_id",                      limit: 4
    t.integer  "invoice_detail_large_classification_id", limit: 4
    t.integer  "invoice_item_division_id",               limit: 4
    t.integer  "working_middle_item_id",                 limit: 4
    t.string   "working_middle_item_name",               limit: 255
    t.string   "working_middle_item_short_name",         limit: 255
    t.integer  "line_number",                            limit: 4
    t.string   "working_middle_specification",           limit: 255
    t.integer  "quantity",                               limit: 4
    t.integer  "execution_quantity",                     limit: 4
    t.integer  "working_unit_id",                        limit: 4
    t.string   "working_unit_name",                      limit: 255
    t.integer  "working_unit_price",                     limit: 4
    t.string   "invoice_price",                          limit: 255
    t.integer  "execution_unit_price",                   limit: 4
    t.string   "execution_price",                        limit: 255
    t.integer  "material_id",                            limit: 4
    t.string   "working_material_name",                  limit: 255
    t.integer  "material_unit_price",                    limit: 4
    t.float    "labor_unit_price",                       limit: 24
    t.float    "labor_productivity_unit",                limit: 24
    t.float    "labor_productivity_unit_total",          limit: 24
    t.integer  "material_quantity",                      limit: 4
    t.integer  "accessory_cost",                         limit: 4
    t.integer  "material_cost_total",                    limit: 4
    t.integer  "labor_cost_total",                       limit: 4
    t.integer  "other_cost",                             limit: 4
    t.string   "remarks",                                limit: 255
    t.integer  "construction_type",                      limit: 4
    t.integer  "piping_wiring_flag",                     limit: 4
    t.integer  "equipment_mounting_flag",                limit: 4
    t.integer  "labor_cost_flag",                        limit: 4
    t.datetime "created_at",                                         null: false
    t.datetime "updated_at",                                         null: false
  end

  create_table "invoice_headers", force: :cascade do |t|
    t.string   "invoice_code",              limit: 255
    t.string   "quotation_code",            limit: 255
    t.string   "delivery_slip_code",        limit: 255
    t.date     "invoice_date"
    t.integer  "construction_datum_id",     limit: 4
    t.string   "construction_name",         limit: 255
    t.integer  "customer_id",               limit: 4
    t.string   "customer_name",             limit: 255
    t.integer  "honorific_id",              limit: 4
    t.string   "responsible1",              limit: 255
    t.string   "responsible2",              limit: 255
    t.string   "post",                      limit: 255
    t.string   "address",                   limit: 255
    t.string   "tel",                       limit: 255
    t.string   "fax",                       limit: 255
    t.string   "construction_period",       limit: 255
    t.string   "construction_place",        limit: 255
    t.string   "payment_period",            limit: 255
    t.date     "invoice_period_start_date"
    t.date     "invoice_period_end_date"
    t.integer  "billing_amount",            limit: 4
    t.integer  "execution_amount",          limit: 4
    t.integer  "deposit_amount",            limit: 4
    t.integer  "payment_method_id",         limit: 4
    t.integer  "commission",                limit: 4
    t.date     "payment_date"
    t.integer  "last_line_number",          limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "maker_masters", force: :cascade do |t|
    t.string   "maker_name", limit: 255
    t.datetime "created_at",             null: false
    t.datetime "update_at",              null: false
  end

  create_table "material_masters", force: :cascade do |t|
    t.string   "material_code",                    limit: 255
    t.string   "material_name",                    limit: 255
    t.integer  "maker_id",                         limit: 4
    t.integer  "unit_id",                          limit: 4
    t.integer  "list_price",                       limit: 4
    t.integer  "standard_quantity",                limit: 4
    t.float    "standard_labor_productivity_unit", limit: 24
    t.float    "last_unit_price",                  limit: 24
    t.date     "last_unit_price_update_at"
    t.integer  "inventory_category_id",            limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "update_at",                                    null: false
  end

  create_table "orders", force: :cascade do |t|
    t.integer  "purchase_order_history_id", limit: 4
    t.integer  "material_id",               limit: 4
    t.string   "material_code",             limit: 255
    t.string   "material_name",             limit: 255
    t.integer  "maker_id",                  limit: 4
    t.string   "maker_name",                limit: 255
    t.integer  "quantity",                  limit: 4
    t.integer  "unit_master_id",            limit: 4
    t.integer  "list_price",                limit: 4
    t.integer  "mail_sent_flag",            limit: 4
    t.integer  "sequential_id",             limit: 4,   null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "orders", ["purchase_order_history_id", "sequential_id"], name: "uk_name", unique: true, using: :btree

  create_table "purchase_data", force: :cascade do |t|
    t.date     "purchase_date"
    t.string   "slip_code",               limit: 255
    t.integer  "purchase_order_datum_id", limit: 4
    t.integer  "construction_datum_id",   limit: 4
    t.integer  "material_id",             limit: 4
    t.string   "material_code",           limit: 255
    t.string   "material_name",           limit: 255
    t.integer  "maker_id",                limit: 4
    t.string   "maker_name",              limit: 255
    t.float    "quantity",                limit: 24
    t.integer  "unit_id",                 limit: 4
    t.float    "purchase_unit_price",     limit: 24
    t.integer  "purchase_amount",         limit: 4
    t.integer  "list_price",              limit: 4
    t.integer  "purchase_id",             limit: 4
    t.integer  "division_id",             limit: 4
    t.integer  "supplier_id",             limit: 4
    t.integer  "inventory_division_id",   limit: 4
    t.string   "notes",                   limit: 255
    t.datetime "created_at",                          null: false
    t.datetime "update_at",                           null: false
  end

  create_table "purchase_divisions", force: :cascade do |t|
    t.string   "purchase_division_name",      limit: 255
    t.string   "purchase_division_long_name", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "update_at",                               null: false
  end

  create_table "purchase_order_data", force: :cascade do |t|
    t.string   "purchase_order_code",   limit: 255
    t.integer  "construction_datum_id", limit: 4
    t.integer  "supplier_master_id",    limit: 4
    t.string   "alias_name",            limit: 255
    t.date     "purchase_order_date"
    t.integer  "mail_sent_flag",        limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "update_at",                         null: false
  end

  create_table "purchase_order_histories", force: :cascade do |t|
    t.date     "purchase_order_date"
    t.integer  "supplier_master_id",      limit: 4
    t.integer  "purchase_order_datum_id", limit: 4
    t.integer  "mail_sent_flag",          limit: 4, default: 0
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "purchase_unit_prices", force: :cascade do |t|
    t.integer  "supplier_id",            limit: 4
    t.integer  "material_id",            limit: 4
    t.string   "supplier_material_code", limit: 255
    t.float    "unit_price",             limit: 24
    t.integer  "list_price",             limit: 4
    t.integer  "unit_id",                limit: 4
    t.datetime "created_at",                         null: false
    t.datetime "update_at",                          null: false
  end

  create_table "quotation_breakdown_histories", force: :cascade do |t|
    t.integer  "quotation_header_history_id",   limit: 4
    t.integer  "quotation_items_division_id",   limit: 4
    t.integer  "working_large_item_id",         limit: 4
    t.string   "working_large_item_name",       limit: 255
    t.string   "working_large_item_short_name", limit: 255
    t.string   "working_large_specification",   limit: 255
    t.integer  "line_number",                   limit: 4
    t.integer  "quantity",                      limit: 4
    t.integer  "execution_quantity",            limit: 4
    t.integer  "working_unit_id",               limit: 4
    t.integer  "working_unit_name",             limit: 4
    t.integer  "working_unit_price",            limit: 4
    t.string   "quote_price",                   limit: 255
    t.integer  "execution_unit_price",          limit: 4
    t.string   "execution_price",               limit: 255
    t.float    "labor_productivity_unit",       limit: 24
    t.float    "labor_productivity_unit_total", limit: 24
    t.integer  "last_line_number",              limit: 4
    t.string   "remarks",                       limit: 255
    t.integer  "construction_type",             limit: 4
    t.integer  "piping_wiring_flag",            limit: 4
    t.integer  "equipment_mounting_flag",       limit: 4
    t.integer  "labor_cost_flag",               limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "quotation_detail_large_classifications", force: :cascade do |t|
    t.integer  "quotation_header_id",           limit: 4
    t.integer  "quotation_items_division_id",   limit: 4
    t.integer  "working_large_item_id",         limit: 4
    t.string   "working_large_item_name",       limit: 255
    t.string   "working_large_item_short_name", limit: 255
    t.string   "working_large_specification",   limit: 255
    t.integer  "line_number",                   limit: 4
    t.integer  "quantity",                      limit: 4
    t.integer  "execution_quantity",            limit: 4
    t.integer  "working_unit_id",               limit: 4
    t.string   "working_unit_name",             limit: 255
    t.integer  "working_unit_price",            limit: 4
    t.string   "quote_price",                   limit: 255
    t.integer  "execution_unit_price",          limit: 4
    t.string   "execution_price",               limit: 255
    t.float    "labor_productivity_unit",       limit: 24
    t.float    "labor_productivity_unit_total", limit: 24
    t.integer  "last_line_number",              limit: 4
    t.string   "remarks",                       limit: 255
    t.integer  "construction_type",             limit: 4
    t.integer  "piping_wiring_flag",            limit: 4
    t.integer  "equipment_mounting_flag",       limit: 4
    t.integer  "labor_cost_flag",               limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "quotation_detail_middle_classifications", force: :cascade do |t|
    t.integer  "quotation_header_id",                      limit: 4
    t.integer  "quotation_detail_large_classification_id", limit: 4
    t.integer  "quotation_items_division_id",              limit: 4
    t.integer  "working_middle_item_id",                   limit: 4
    t.string   "working_middle_item_name",                 limit: 255
    t.string   "working_middle_item_short_name",           limit: 255
    t.integer  "line_number",                              limit: 4
    t.string   "working_middle_specification",             limit: 255
    t.integer  "quantity",                                 limit: 4
    t.integer  "execution_quantity",                       limit: 4
    t.integer  "working_unit_id",                          limit: 4
    t.string   "working_unit_name",                        limit: 255
    t.integer  "working_unit_price",                       limit: 4
    t.string   "quote_price",                              limit: 255
    t.integer  "execution_unit_price",                     limit: 4
    t.string   "execution_price",                          limit: 255
    t.integer  "material_id",                              limit: 4
    t.string   "quotation_material_name",                  limit: 255
    t.integer  "material_unit_price",                      limit: 4
    t.float    "labor_unit_price",                         limit: 24
    t.float    "labor_productivity_unit",                  limit: 24
    t.float    "labor_productivity_unit_total",            limit: 24
    t.integer  "material_quantity",                        limit: 4
    t.integer  "accessory_cost",                           limit: 4
    t.integer  "material_cost_total",                      limit: 4
    t.integer  "labor_cost_total",                         limit: 4
    t.integer  "other_cost",                               limit: 4
    t.string   "remarks",                                  limit: 255
    t.integer  "construction_type",                        limit: 4
    t.integer  "piping_wiring_flag",                       limit: 4
    t.integer  "equipment_mounting_flag",                  limit: 4
    t.integer  "labor_cost_flag",                          limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  create_table "quotation_details_histories", force: :cascade do |t|
    t.integer  "quotation_header_history_id",    limit: 4
    t.integer  "quotation_breakdown_history_id", limit: 4
    t.integer  "working_middle_item_id",         limit: 4
    t.string   "working_middle_item_name",       limit: 255
    t.string   "working_middle_item_short_name", limit: 255
    t.integer  "line_number",                    limit: 4
    t.string   "working_middle_specification",   limit: 255
    t.integer  "quantity",                       limit: 4
    t.integer  "execution_quantity",             limit: 4
    t.integer  "working_unit_id",                limit: 4
    t.string   "working_unit_name",              limit: 255
    t.integer  "working_unit_price",             limit: 4
    t.string   "quote_price",                    limit: 255
    t.integer  "execution_unit_price",           limit: 4
    t.string   "execution_price",                limit: 255
    t.float    "labor_productivity_unit",        limit: 24
    t.float    "labor_productivity_unit_total",  limit: 24
    t.string   "remarks",                        limit: 255
    t.integer  "construction_type",              limit: 4
    t.integer  "piping_wiring_flag",             limit: 4
    t.integer  "equipment_mounting_flag",        limit: 4
    t.integer  "labor_cost_flag",                limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "quotation_header_histories", force: :cascade do |t|
    t.datetime "issue_date"
    t.integer  "quotation_header_id",   limit: 4
    t.string   "quotation_code",        limit: 255
    t.string   "invoice_code",          limit: 255
    t.string   "delivery_slip_code",    limit: 255
    t.date     "quotation_date"
    t.integer  "construction_datum_id", limit: 4
    t.string   "construction_name",     limit: 255
    t.integer  "customer_id",           limit: 4
    t.string   "customer_name",         limit: 255
    t.integer  "honorific_id",          limit: 4
    t.string   "responsible1",          limit: 255
    t.string   "responsible2",          limit: 255
    t.string   "post",                  limit: 255
    t.string   "address",               limit: 255
    t.string   "tel",                   limit: 255
    t.string   "fax",                   limit: 255
    t.string   "construction_period",   limit: 255
    t.string   "construction_place",    limit: 255
    t.string   "trading_method",        limit: 255
    t.string   "effective_period",      limit: 255
    t.integer  "quote_price",           limit: 4
    t.integer  "execution_amount",      limit: 4
    t.integer  "net_amount",            limit: 4
    t.integer  "last_line_number",      limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "quotation_headers", force: :cascade do |t|
    t.string   "quotation_code",            limit: 255
    t.string   "invoice_code",              limit: 255
    t.string   "delivery_slip_code",        limit: 255
    t.date     "quotation_date"
    t.integer  "construction_datum_id",     limit: 4
    t.string   "construction_name",         limit: 255
    t.integer  "customer_id",               limit: 4
    t.string   "customer_name",             limit: 255
    t.integer  "honorific_id",              limit: 4
    t.string   "responsible1",              limit: 255
    t.string   "responsible2",              limit: 255
    t.string   "post",                      limit: 255
    t.string   "address",                   limit: 255
    t.string   "tel",                       limit: 255
    t.string   "fax",                       limit: 255
    t.string   "construction_period",       limit: 255
    t.string   "construction_place",        limit: 255
    t.string   "trading_method",            limit: 255
    t.string   "effective_period",          limit: 255
    t.integer  "quote_price",               limit: 4
    t.integer  "execution_amount",          limit: 4
    t.integer  "net_amount",                limit: 4
    t.integer  "last_line_number",          limit: 4
    t.date     "invoice_period_start_date"
    t.date     "invoice_period_end_date"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "quotation_items_divisions", force: :cascade do |t|
    t.string   "quotation_items_division_name", limit: 255
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "quotation_large_items", force: :cascade do |t|
    t.string   "quotation_large_item_name",     limit: 255
    t.string   "quotation_large_specification", limit: 255
    t.integer  "working_unit_id",               limit: 4
    t.integer  "quotation_unit_price",          limit: 4
    t.integer  "execution_unit_price",          limit: 4
    t.float    "labor_productivity_unit",       limit: 24
    t.float    "labor_productivity_unit_total", limit: 24
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "quotation_middle_items", force: :cascade do |t|
    t.string   "quotation_middle_item_name",       limit: 255
    t.string   "quotation_middle_item_short_name", limit: 255
    t.string   "quotation_middle_specification",   limit: 255
    t.integer  "working_unit_id",                  limit: 4
    t.integer  "quotation_unit_price",             limit: 4
    t.integer  "execution_unit_price",             limit: 4
    t.integer  "material_id",                      limit: 4
    t.string   "quotation_material_name",          limit: 255
    t.integer  "material_unit_price",              limit: 4
    t.float    "labor_unit_price",                 limit: 24
    t.float    "labor_productivity_unit",          limit: 24
    t.float    "labor_productivity_unit_total",    limit: 24
    t.integer  "material_quantity",                limit: 4
    t.integer  "accessory_cost",                   limit: 4
    t.integer  "material_cost_total",              limit: 4
    t.integer  "labor_cost_total",                 limit: 4
    t.integer  "other_cost",                       limit: 4
    t.datetime "created_at",                                   null: false
    t.datetime "updated_at",                                   null: false
  end

  create_table "quotation_units", force: :cascade do |t|
    t.string   "quotation_unit_name", limit: 255
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "staffs", force: :cascade do |t|
    t.string   "staff_name",     limit: 255
    t.string   "furigana",       limit: 255
    t.integer  "affiliation_id", limit: 4
    t.integer  "hourly_wage",    limit: 4
    t.integer  "daily_pay",      limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "update_at",                  null: false
  end

  create_table "stocktakes", force: :cascade do |t|
    t.date     "stocktake_date"
    t.integer  "material_master_id",    limit: 4
    t.integer  "inventory_id",          limit: 4
    t.integer  "physical_quantity",     limit: 4
    t.float    "unit_price",            limit: 24
    t.integer  "physical_amount",       limit: 4
    t.integer  "book_quantity",         limit: 4
    t.integer  "book_amount",           limit: 4
    t.integer  "inventory_update_flag", limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "supplier_masters", force: :cascade do |t|
    t.string   "supplier_name", limit: 255
    t.string   "tel_main",      limit: 255
    t.string   "fax_main",      limit: 255
    t.string   "email_main",    limit: 255
    t.string   "responsible1",  limit: 255
    t.string   "email1",        limit: 255
    t.string   "responsible2",  limit: 255
    t.string   "email2",        limit: 255
    t.string   "responsible3",  limit: 255
    t.string   "email3",        limit: 255
    t.datetime "created_at",                null: false
    t.datetime "update_at",                 null: false
  end

  create_table "test", id: false, force: :cascade do |t|
    t.integer "num",  limit: 4
    t.string  "name", limit: 50
  end

  create_table "unit_masters", force: :cascade do |t|
    t.string   "unit_name",  limit: 255
    t.datetime "created_at",             null: false
    t.datetime "update_at",              null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name",                  limit: 255
    t.string   "email",                 limit: 255
    t.string   "password",              limit: 255
    t.string   "password_confirmation", limit: 255
    t.string   "password_digest",       limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "working_large_items", force: :cascade do |t|
    t.string   "working_large_item_name",       limit: 255
    t.string   "working_large_item_short_name", limit: 255
    t.string   "working_large_specification",   limit: 255
    t.integer  "working_unit_id",               limit: 4
    t.integer  "working_unit_price",            limit: 4
    t.integer  "execution_unit_price",          limit: 4
    t.float    "execution_material_unit_price", limit: 24
    t.float    "material_unit_price",           limit: 24
    t.float    "execution_labor_unit_price",    limit: 24
    t.float    "labor_unit_price",              limit: 24
    t.float    "labor_productivity_unit",       limit: 24
    t.float    "labor_productivity_unit_total", limit: 24
    t.integer  "seq",                           limit: 4
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  create_table "working_middle_items", force: :cascade do |t|
    t.string   "working_middle_item_name",       limit: 255
    t.string   "working_middle_item_short_name", limit: 255
    t.string   "working_middle_specification",   limit: 255
    t.integer  "working_unit_id",                limit: 4
    t.float    "working_unit_price",             limit: 24
    t.integer  "execution_unit_price",           limit: 4
    t.integer  "material_id",                    limit: 4
    t.string   "working_material_name",          limit: 255
    t.float    "execution_material_unit_price",  limit: 24
    t.float    "material_unit_price",            limit: 24
    t.float    "execution_labor_unit_price",     limit: 24
    t.float    "labor_unit_price",               limit: 24
    t.integer  "labor_unit_price_standard",      limit: 4
    t.float    "labor_productivity_unit",        limit: 24
    t.float    "labor_productivity_unit_total",  limit: 24
    t.integer  "material_quantity",              limit: 4
    t.integer  "accessory_cost",                 limit: 4
    t.integer  "material_cost_total",            limit: 4
    t.integer  "labor_cost_total",               limit: 4
    t.integer  "other_cost",                     limit: 4
    t.integer  "seq",                            limit: 4
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
  end

  create_table "working_safety_matters", force: :cascade do |t|
    t.string   "working_safety_matter_name", limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "working_small_items", force: :cascade do |t|
    t.integer  "working_middle_item_id",  limit: 4
    t.integer  "working_small_item_id",   limit: 4
    t.string   "working_small_item_code", limit: 255
    t.string   "working_small_item_name", limit: 255
    t.float    "unit_price",              limit: 24
    t.integer  "quantity",                limit: 4
    t.float    "labor_productivity_unit", limit: 24
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "working_times_detail_data", force: :cascade do |t|
    t.integer  "employee_id",                               limit: 4
    t.date     "working_date"
    t.string   "attendance_kubun",                          limit: 2
    t.time     "opening_time"
    t.time     "closing_time"
    t.time     "working_times"
    t.time     "normal_overtime_time"
    t.time     "late_night_overtime_time"
    t.time     "saturday_holiday_working_time"
    t.time     "saturday_holiday_overtime_time"
    t.time     "saturday_holiday_late_night_overtime_time"
    t.time     "sunday_working_time"
    t.time     "sunday_overtime_time"
    t.time     "sunday_late_night_overtime_time"
    t.integer  "amount",                                    limit: 4
    t.boolean  "check_president"
    t.boolean  "check_general_affair"
    t.datetime "created"
    t.datetime "modified"
  end

  add_index "working_times_detail_data", ["employee_id", "working_date"], name: "employee_id", unique: true, using: :btree

  create_table "working_times_heading_data", force: :cascade do |t|
    t.integer  "employee_id",                                      limit: 4
    t.string   "working_year_month",                               limit: 6
    t.time     "working_times_sum"
    t.integer  "working_times_amount",                             limit: 4
    t.time     "normal_overtime_time_sum"
    t.integer  "normal_overtime_time_amount",                      limit: 4
    t.time     "late_night_overtime_time_sum"
    t.integer  "late_night_overtime_time_amount",                  limit: 4
    t.time     "saturday_holiday_working_time_sum"
    t.integer  "saturday_holiday_working_time_amount",             limit: 4
    t.time     "saturday_holiday_overtime_time_sum"
    t.integer  "saturday_holiday_overtime_time_amount",            limit: 4
    t.time     "saturday_holiday_late_night_overtime_time_sum"
    t.integer  "saturday_holiday_late_night_overtime_time_amount", limit: 4
    t.time     "sunday_working_time_sum"
    t.integer  "sunday_working_time_amount",                       limit: 4
    t.time     "sunday_overtime_time_sum"
    t.integer  "sunday_overtime_time_amount",                      limit: 4
    t.time     "sunday_late_night_overtime_time_sum"
    t.integer  "sunday_late_night_overtime_time_amount",           limit: 4
    t.integer  "sum_amount",                                       limit: 4
    t.datetime "created"
    t.datetime "modified"
  end

  add_index "working_times_heading_data", ["employee_id", "working_year_month"], name: "employee_id", unique: true, using: :btree

  create_table "working_units", force: :cascade do |t|
    t.string   "working_unit_name", limit: 255
    t.integer  "seq",               limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

end
