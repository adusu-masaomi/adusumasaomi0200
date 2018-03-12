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

ActiveRecord::Schema.define(version: 20180223022929) do

  create_table "account_account_title", force: :cascade do |t|
    t.string   "name",              limit: 255,               null: false
    t.integer  "trade_division_id", limit: 4,                 null: false
    t.datetime "created_at",                    precision: 6
    t.datetime "update_at",                     precision: 6
  end

  create_table "account_bank", force: :cascade do |t|
    t.string   "name",       limit: 255,               null: false
    t.datetime "created_at",             precision: 6
    t.datetime "update_at",              precision: 6
  end

  create_table "account_bank_branch", force: :cascade do |t|
    t.string   "name",       limit: 255,               null: false
    t.integer  "bank_id",    limit: 4
    t.datetime "created_at",             precision: 6
    t.datetime "update_at",              precision: 6
  end

  add_index "account_bank_branch", ["bank_id"], name: "account_bank_branch_0b0af02d", using: :btree

  create_table "account_partner", force: :cascade do |t|
    t.string   "name",              limit: 255,               null: false
    t.integer  "trade_division_id", limit: 4,                 null: false
    t.integer  "account_title_id",  limit: 4,                 null: false
    t.integer  "payment_method_id", limit: 4,                 null: false
    t.string   "bank_name",         limit: 255,               null: false
    t.string   "branch_name",       limit: 255,               null: false
    t.integer  "account_type",      limit: 4,                 null: false
    t.integer  "account_number",    limit: 4,                 null: false
    t.integer  "pay_day",           limit: 4,                 null: false
    t.boolean  "pay_month_flag_1",                            null: false
    t.boolean  "pay_month_flag_10",                           null: false
    t.boolean  "pay_month_flag_11",                           null: false
    t.boolean  "pay_month_flag_12",                           null: false
    t.boolean  "pay_month_flag_2",                            null: false
    t.boolean  "pay_month_flag_3",                            null: false
    t.boolean  "pay_month_flag_4",                            null: false
    t.boolean  "pay_month_flag_5",                            null: false
    t.boolean  "pay_month_flag_6",                            null: false
    t.boolean  "pay_month_flag_7",                            null: false
    t.boolean  "pay_month_flag_8",                            null: false
    t.boolean  "pay_month_flag_9",                            null: false
    t.integer  "pay_day_division",  limit: 4,                 null: false
    t.integer  "bank_id",           limit: 4
    t.integer  "bank_branch_id",    limit: 4
    t.datetime "created_at",                    precision: 6
    t.datetime "update_at",                     precision: 6
  end

  add_index "account_partner", ["bank_branch_id"], name: "account_partner_a5ad8034", using: :btree
  add_index "account_partner", ["bank_id"], name: "account_partner_0b0af02d", using: :btree

  create_table "account_payment", force: :cascade do |t|
    t.date     "billing_year_month",                           null: false
    t.integer  "trade_division_id",  limit: 4
    t.integer  "billing_amount",     limit: 4,                 null: false
    t.integer  "payment_method_id",  limit: 4,                 null: false
    t.date     "payment_due_date"
    t.date     "payment_date"
    t.boolean  "fixed_cost",                                   null: false
    t.string   "note",               limit: 255,               null: false
    t.datetime "created_at",                     precision: 6
    t.datetime "update_at",                      precision: 6
    t.integer  "account_title_id",   limit: 4
    t.integer  "partner_id",         limit: 4
  end

  add_index "account_payment", ["account_title_id"], name: "account_pa_account_title_id_de8d3cfe_fk_account_account_title_id", using: :btree
  add_index "account_payment", ["partner_id"], name: "account_payment_partner_id_efa46d84_fk_account_partner_id", using: :btree

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

  create_table "auth_group", force: :cascade do |t|
    t.string "name", limit: 80, null: false
  end

  add_index "auth_group", ["name"], name: "name", unique: true, using: :btree

  create_table "auth_group_permissions", force: :cascade do |t|
    t.integer "group_id",      limit: 4, null: false
    t.integer "permission_id", limit: 4, null: false
  end

  add_index "auth_group_permissions", ["group_id", "permission_id"], name: "auth_group_permissions_group_id_0cd325b0_uniq", unique: true, using: :btree
  add_index "auth_group_permissions", ["permission_id"], name: "auth_group_permissi_permission_id_84c5c92e_fk_auth_permission_id", using: :btree

  create_table "auth_permission", force: :cascade do |t|
    t.string  "name",            limit: 255, null: false
    t.integer "content_type_id", limit: 4,   null: false
    t.string  "codename",        limit: 100, null: false
  end

  add_index "auth_permission", ["content_type_id", "codename"], name: "auth_permission_content_type_id_01ab375a_uniq", unique: true, using: :btree

  create_table "auth_user", force: :cascade do |t|
    t.string   "password",     limit: 128,               null: false
    t.datetime "last_login",               precision: 6
    t.boolean  "is_superuser",                           null: false
    t.string   "username",     limit: 30,                null: false
    t.string   "first_name",   limit: 30,                null: false
    t.string   "last_name",    limit: 30,                null: false
    t.string   "email",        limit: 254,               null: false
    t.boolean  "is_staff",                               null: false
    t.boolean  "is_active",                              null: false
    t.datetime "date_joined",              precision: 6, null: false
  end

  add_index "auth_user", ["username"], name: "username", unique: true, using: :btree

  create_table "auth_user_groups", force: :cascade do |t|
    t.integer "user_id",  limit: 4, null: false
    t.integer "group_id", limit: 4, null: false
  end

  add_index "auth_user_groups", ["group_id"], name: "auth_user_groups_group_id_97559544_fk_auth_group_id", using: :btree
  add_index "auth_user_groups", ["user_id", "group_id"], name: "auth_user_groups_user_id_94350c0c_uniq", unique: true, using: :btree

  create_table "auth_user_user_permissions", force: :cascade do |t|
    t.integer "user_id",       limit: 4, null: false
    t.integer "permission_id", limit: 4, null: false
  end

  add_index "auth_user_user_permissions", ["permission_id"], name: "auth_user_user_perm_permission_id_1fbb5f2c_fk_auth_permission_id", using: :btree
  add_index "auth_user_user_permissions", ["user_id", "permission_id"], name: "auth_user_user_permissions_user_id_14a6b632_uniq", unique: true, using: :btree

  create_table "business_holidays", force: :cascade do |t|
    t.date     "working_date"
    t.integer  "holiday_flag", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "constants", force: :cascade do |t|
    t.string   "purchase_order_last_header_code", limit: 255
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
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
    t.string   "house_number",               limit: 255
    t.string   "address2",                   limit: 255
    t.decimal  "latitude",                               precision: 9, scale: 6
    t.decimal  "longitude",                              precision: 9, scale: 6
    t.string   "construction_detail",        limit: 255
    t.string   "attention_matter",           limit: 255
    t.integer  "working_safety_matter_id",   limit: 4
    t.string   "working_safety_matter_name", limit: 255
    t.integer  "quotation_header_id",        limit: 4
    t.integer  "delivery_slip_header_id",    limit: 4
    t.integer  "billed_flag",                limit: 4
    t.integer  "calculated_flag",            limit: 4
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
    t.string   "customer_name",         limit: 255
    t.string   "search_character",      limit: 255
    t.string   "post",                  limit: 255
    t.string   "address",               limit: 255
    t.string   "house_number",          limit: 255
    t.string   "address2",              limit: 255
    t.string   "tel_main",              limit: 255
    t.string   "fax_main",              limit: 255
    t.string   "email_main",            limit: 255
    t.integer  "closing_date",          limit: 4
    t.integer  "closing_date_division", limit: 4
    t.integer  "due_date",              limit: 4
    t.integer  "due_date_division",     limit: 4
    t.integer  "honorific_id",          limit: 4
    t.string   "responsible1",          limit: 255
    t.string   "responsible2",          limit: 255
    t.integer  "contact_id",            limit: 4
    t.datetime "created_at",                        null: false
    t.datetime "update_at",                         null: false
  end

  create_table "delivery_slip_detail_large_classifications", force: :cascade do |t|
    t.integer  "delivery_slip_header_id",                 limit: 4
    t.integer  "delivery_slip_items_division_id",         limit: 4
    t.integer  "working_large_item_id",                   limit: 4
    t.integer  "working_specific_middle_item_id",         limit: 4
    t.string   "working_large_item_name",                 limit: 255
    t.string   "working_large_item_short_name",           limit: 255
    t.integer  "working_middle_item_category_id",         limit: 4
    t.integer  "working_middle_item_category_id_call",    limit: 4
    t.integer  "working_middle_item_subcategory_id",      limit: 4
    t.integer  "working_middle_item_subcategory_id_call", limit: 4
    t.string   "working_large_specification",             limit: 255
    t.integer  "line_number",                             limit: 4
    t.integer  "quantity",                                limit: 4
    t.integer  "execution_quantity",                      limit: 4
    t.integer  "working_unit_id",                         limit: 4
    t.string   "working_unit_name",                       limit: 255
    t.integer  "working_unit_price",                      limit: 4
    t.string   "delivery_slip_price",                     limit: 255
    t.integer  "execution_unit_price",                    limit: 4
    t.string   "execution_price",                         limit: 255
    t.float    "labor_productivity_unit",                 limit: 24
    t.float    "labor_productivity_unit_total",           limit: 24
    t.integer  "last_line_number",                        limit: 4
    t.string   "remarks",                                 limit: 255
    t.integer  "construction_type",                       limit: 4
    t.integer  "piping_wiring_flag",                      limit: 4
    t.integer  "equipment_mounting_flag",                 limit: 4
    t.integer  "labor_cost_flag",                         limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "delivery_slip_detail_middle_classifications", force: :cascade do |t|
    t.integer  "delivery_slip_header_id",                      limit: 4
    t.integer  "delivery_slip_detail_large_classification_id", limit: 4
    t.integer  "delivery_slip_item_division_id",               limit: 4
    t.integer  "working_middle_item_id",                       limit: 4
    t.integer  "working_specific_middle_item_id",              limit: 4
    t.string   "working_middle_item_name",                     limit: 255
    t.string   "working_middle_item_short_name",               limit: 255
    t.integer  "working_middle_item_category_id",              limit: 4
    t.integer  "working_middle_item_category_id_call",         limit: 4
    t.integer  "working_middle_item_subcategory_id",           limit: 4
    t.integer  "working_middle_item_subcategory_id_call",      limit: 4
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
    t.string   "delivery_slip_code",        limit: 255
    t.string   "quotation_code",            limit: 255
    t.string   "invoice_code",              limit: 255
    t.date     "delivery_slip_date"
    t.integer  "construction_datum_id",     limit: 4
    t.string   "construction_name",         limit: 255
    t.integer  "customer_id",               limit: 4
    t.string   "customer_name",             limit: 255
    t.integer  "honorific_id",              limit: 4
    t.string   "responsible1",              limit: 255
    t.string   "responsible2",              limit: 255
    t.string   "post",                      limit: 255
    t.string   "address",                   limit: 255
    t.string   "house_number",              limit: 255
    t.string   "address2",                  limit: 255
    t.string   "tel",                       limit: 255
    t.string   "fax",                       limit: 255
    t.string   "construction_period",       limit: 255
    t.string   "construction_post",         limit: 255
    t.string   "construction_place",        limit: 255
    t.string   "construction_house_number", limit: 255
    t.string   "construction_place2",       limit: 255
    t.integer  "delivery_amount",           limit: 4
    t.integer  "execution_amount",          limit: 4
    t.integer  "last_line_number",          limit: 4
    t.integer  "category_saved_flag",       limit: 4
    t.integer  "category_saved_id",         limit: 4
    t.integer  "subcategory_saved_id",      limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "django_admin_log", force: :cascade do |t|
    t.datetime "action_time",                        precision: 6, null: false
    t.text     "object_id",       limit: 4294967295
    t.string   "object_repr",     limit: 200,                      null: false
    t.integer  "action_flag",     limit: 2,                        null: false
    t.text     "change_message",  limit: 4294967295,               null: false
    t.integer  "content_type_id", limit: 4
    t.integer  "user_id",         limit: 4,                        null: false
  end

  add_index "django_admin_log", ["content_type_id"], name: "django_admin__content_type_id_c4bce8eb_fk_django_content_type_id", using: :btree
  add_index "django_admin_log", ["user_id"], name: "django_admin_log_user_id_c564eba6_fk_auth_user_id", using: :btree

  create_table "django_content_type", force: :cascade do |t|
    t.string "app_label", limit: 100, null: false
    t.string "model",     limit: 100, null: false
  end

  add_index "django_content_type", ["app_label", "model"], name: "django_content_type_app_label_76bd3d3b_uniq", unique: true, using: :btree

  create_table "django_migrations", force: :cascade do |t|
    t.string   "app",     limit: 255,               null: false
    t.string   "name",    limit: 255,               null: false
    t.datetime "applied",             precision: 6, null: false
  end

  create_table "django_session", primary_key: "session_key", force: :cascade do |t|
    t.text     "session_data", limit: 4294967295,               null: false
    t.datetime "expire_date",                     precision: 6, null: false
  end

  add_index "django_session", ["expire_date"], name: "django_session_de54fa62", using: :btree

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
    t.string   "image",                    limit: 255
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
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
    t.string   "house_number",              limit: 255
    t.string   "address2",                  limit: 255
    t.string   "tel",                       limit: 255
    t.string   "fax",                       limit: 255
    t.string   "construction_period",       limit: 255
    t.string   "construction_place",        limit: 255
    t.string   "construction_house_number", limit: 255
    t.string   "construction_place2",       limit: 255
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
    t.string   "remarks",                   limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "links", force: :cascade do |t|
    t.integer  "construction_datum_id", limit: 4
    t.integer  "source",                limit: 4
    t.integer  "target",                limit: 4
    t.string   "link_type",             limit: 255
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
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

  add_index "orders", ["purchase_order_history_id", "sequential_id"], name: "uq_seq", unique: true, using: :btree

  create_table "purchase_data", force: :cascade do |t|
    t.date     "purchase_date"
    t.string   "slip_code",                  limit: 255
    t.integer  "purchase_order_datum_id",    limit: 4
    t.integer  "construction_datum_id",      limit: 4
    t.integer  "material_id",                limit: 4
    t.string   "material_code",              limit: 255
    t.string   "material_name",              limit: 255
    t.integer  "maker_id",                   limit: 4
    t.string   "maker_name",                 limit: 255
    t.float    "quantity",                   limit: 24
    t.integer  "unit_id",                    limit: 4
    t.float    "purchase_unit_price",        limit: 24
    t.integer  "purchase_amount",            limit: 4
    t.integer  "list_price",                 limit: 4
    t.integer  "purchase_id",                limit: 4
    t.integer  "division_id",                limit: 4
    t.integer  "supplier_id",                limit: 4
    t.integer  "inventory_division_id",      limit: 4
    t.integer  "unit_price_not_update_flag", limit: 4
    t.string   "notes",                      limit: 255
    t.datetime "created_at",                             null: false
    t.datetime "update_at",                              null: false
  end

  create_table "purchase_divisions", force: :cascade do |t|
    t.string   "purchase_division_name",      limit: 255
    t.string   "purchase_division_long_name", limit: 255
    t.datetime "created_at",                              null: false
    t.datetime "update_at",                               null: false
  end

  create_table "purchase_headers", force: :cascade do |t|
    t.string   "slip_code",         limit: 255
    t.integer  "registration_flag", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
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
    t.integer  "quotation_header_id",                     limit: 4
    t.integer  "quotation_items_division_id",             limit: 4
    t.integer  "working_large_item_id",                   limit: 4
    t.integer  "working_specific_middle_item_id",         limit: 4
    t.string   "working_large_item_name",                 limit: 255
    t.string   "working_large_item_short_name",           limit: 255
    t.integer  "working_middle_item_category_id",         limit: 4
    t.integer  "working_middle_item_category_id_call",    limit: 4
    t.integer  "working_middle_item_subcategory_id",      limit: 4
    t.integer  "working_middle_item_subcategory_id_call", limit: 4
    t.string   "working_large_specification",             limit: 255
    t.integer  "line_number",                             limit: 4
    t.integer  "quantity",                                limit: 4
    t.integer  "execution_quantity",                      limit: 4
    t.integer  "working_unit_id",                         limit: 4
    t.string   "working_unit_name",                       limit: 255
    t.integer  "working_unit_price",                      limit: 4
    t.string   "quote_price",                             limit: 255
    t.integer  "execution_unit_price",                    limit: 4
    t.string   "execution_price",                         limit: 255
    t.float    "labor_productivity_unit",                 limit: 24
    t.float    "labor_productivity_unit_total",           limit: 24
    t.integer  "last_line_number",                        limit: 4
    t.string   "remarks",                                 limit: 255
    t.integer  "construction_type",                       limit: 4
    t.integer  "piping_wiring_flag",                      limit: 4
    t.integer  "equipment_mounting_flag",                 limit: 4
    t.integer  "labor_cost_flag",                         limit: 4
    t.datetime "created_at",                                          null: false
    t.datetime "updated_at",                                          null: false
  end

  create_table "quotation_detail_middle_classifications", force: :cascade do |t|
    t.integer  "quotation_header_id",                      limit: 4
    t.integer  "quotation_detail_large_classification_id", limit: 4
    t.integer  "quotation_items_division_id",              limit: 4
    t.integer  "working_middle_item_id",                   limit: 4
    t.integer  "working_specific_middle_item_id",          limit: 4
    t.string   "working_middle_item_name",                 limit: 255
    t.string   "working_middle_item_short_name",           limit: 255
    t.integer  "working_middle_item_category_id",          limit: 4
    t.integer  "working_middle_item_category_id_call",     limit: 4
    t.integer  "working_middle_item_subcategory_id",       limit: 4
    t.integer  "working_middle_item_subcategory_id_call",  limit: 4
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
    t.string   "quotation_code",             limit: 255
    t.string   "invoice_code",               limit: 255
    t.string   "delivery_slip_code",         limit: 255
    t.integer  "quotation_header_origin_id", limit: 4
    t.date     "quotation_date"
    t.integer  "construction_datum_id",      limit: 4
    t.string   "construction_name",          limit: 255
    t.integer  "customer_id",                limit: 4
    t.string   "customer_name",              limit: 255
    t.integer  "honorific_id",               limit: 4
    t.string   "responsible1",               limit: 255
    t.string   "responsible2",               limit: 255
    t.string   "post",                       limit: 255
    t.string   "address",                    limit: 255
    t.string   "house_number",               limit: 255
    t.string   "address2",                   limit: 255
    t.string   "tel",                        limit: 255
    t.string   "fax",                        limit: 255
    t.string   "construction_period",        limit: 255
    t.string   "construction_post",          limit: 255
    t.string   "construction_place",         limit: 255
    t.string   "construction_house_number",  limit: 255
    t.string   "construction_place2",        limit: 255
    t.string   "trading_method",             limit: 255
    t.string   "effective_period",           limit: 255
    t.integer  "quote_price",                limit: 4
    t.integer  "execution_amount",           limit: 4
    t.integer  "net_amount",                 limit: 4
    t.integer  "last_line_number",           limit: 4
    t.integer  "category_saved_flag",        limit: 4
    t.integer  "category_saved_id",          limit: 4
    t.integer  "subcategory_saved_id",       limit: 4
    t.date     "invoice_period_start_date"
    t.date     "invoice_period_end_date"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
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

  create_table "quotation_material_details", force: :cascade do |t|
    t.integer  "quotation_material_header_id", limit: 4
    t.integer  "material_id",                  limit: 4
    t.string   "material_code",                limit: 255
    t.string   "material_name",                limit: 255
    t.integer  "maker_id",                     limit: 4
    t.string   "maker_name",                   limit: 255
    t.integer  "quantity",                     limit: 4
    t.integer  "unit_master_id",               limit: 4
    t.integer  "list_price",                   limit: 4
    t.integer  "quotation_unit_price_1",       limit: 4
    t.integer  "quotation_unit_price_2",       limit: 4
    t.integer  "quotation_unit_price_3",       limit: 4
    t.integer  "quotation_price_1",            limit: 4
    t.integer  "quotation_price_2",            limit: 4
    t.integer  "quotation_price_3",            limit: 4
    t.integer  "bid_flag_1",                   limit: 4
    t.integer  "bid_flag_2",                   limit: 4
    t.integer  "bid_flag_3",                   limit: 4
    t.integer  "mail_sent_flag",               limit: 4
    t.integer  "quotation_email_flag_1",       limit: 4
    t.integer  "quotation_email_flag_2",       limit: 4
    t.integer  "quotation_email_flag_3",       limit: 4
    t.integer  "order_email_flag_1",           limit: 4
    t.integer  "order_email_flag_2",           limit: 4
    t.integer  "order_email_flag_3",           limit: 4
    t.integer  "sequential_id",                limit: 4,   null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "quotation_material_details", ["quotation_material_header_id", "sequential_id"], name: "uq_seq", unique: true, using: :btree

  create_table "quotation_material_headers", force: :cascade do |t|
    t.string   "quotation_code",             limit: 255
    t.date     "requested_date"
    t.integer  "construction_datum_id",      limit: 4
    t.integer  "supplier_master_id",         limit: 4
    t.string   "responsible",                limit: 255
    t.string   "email",                      limit: 255
    t.integer  "quotation_header_origin_id", limit: 4
    t.integer  "total_quotation_price_1",    limit: 4
    t.integer  "total_quotation_price_2",    limit: 4
    t.integer  "total_quotation_price_3",    limit: 4
    t.integer  "total_order_price_1",        limit: 4
    t.integer  "total_order_price_2",        limit: 4
    t.integer  "total_order_price_3",        limit: 4
    t.integer  "supplier_id_1",              limit: 4
    t.integer  "supplier_id_2",              limit: 4
    t.integer  "supplier_id_3",              limit: 4
    t.integer  "quotation_email_flag_1",     limit: 4
    t.integer  "quotation_email_flag_2",     limit: 4
    t.integer  "quotation_email_flag_3",     limit: 4
    t.integer  "order_email_flag_1",         limit: 4
    t.integer  "order_email_flag_2",         limit: 4
    t.integer  "order_email_flag_3",         limit: 4
    t.integer  "all_bid_flag_1",             limit: 4
    t.integer  "all_bid_flag_2",             limit: 4
    t.integer  "all_bid_flag_3",             limit: 4
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
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

  create_table "schedules", force: :cascade do |t|
    t.integer  "construction_datum_id", limit: 4
    t.string   "content_name",          limit: 255
    t.date     "estimated_start_date"
    t.date     "estimated_end_date"
    t.date     "work_start_date"
    t.date     "work_end_date"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
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

  create_table "task_contents", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "tasks", force: :cascade do |t|
    t.integer  "construction_datum_id", limit: 4
    t.string   "text",                  limit: 255
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "work_start_date"
    t.datetime "work_end_date"
    t.integer  "duration",              limit: 4
    t.integer  "parent",                limit: 4
    t.float    "progress",              limit: 24
    t.integer  "sortorder",             limit: 4,   default: 0, null: false
    t.integer  "priority",              limit: 4
    t.string   "color",                 limit: 255
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
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

  create_table "working_categories", force: :cascade do |t|
    t.string   "category_name", limit: 255
    t.integer  "seq",           limit: 4
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
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
    t.string   "working_middle_item_name",        limit: 255
    t.string   "working_middle_item_short_name",  limit: 255
    t.integer  "working_middle_item_category_id", limit: 4
    t.integer  "working_subcategory_id",          limit: 4
    t.string   "working_middle_specification",    limit: 255
    t.integer  "working_unit_id",                 limit: 4
    t.string   "working_unit_name",               limit: 255
    t.float    "working_unit_price",              limit: 24
    t.integer  "execution_unit_price",            limit: 4
    t.integer  "material_id",                     limit: 4
    t.string   "working_material_name",           limit: 255
    t.float    "execution_material_unit_price",   limit: 24
    t.float    "material_unit_price",             limit: 24
    t.float    "execution_labor_unit_price",      limit: 24
    t.float    "labor_unit_price",                limit: 24
    t.integer  "labor_unit_price_standard",       limit: 4
    t.float    "labor_productivity_unit",         limit: 24
    t.float    "labor_productivity_unit_total",   limit: 24
    t.integer  "material_quantity",               limit: 4
    t.integer  "accessory_cost",                  limit: 4
    t.integer  "material_cost_total",             limit: 4
    t.integer  "labor_cost_total",                limit: 4
    t.integer  "other_cost",                      limit: 4
    t.integer  "seq",                             limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
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
    t.float    "rate",                    limit: 24
    t.integer  "quantity",                limit: 4
    t.float    "material_price",          limit: 24
    t.integer  "maker_master_id",         limit: 4
    t.integer  "unit_master_id",          limit: 4
    t.float    "labor_productivity_unit", limit: 24
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "working_specific_middle_items", force: :cascade do |t|
    t.integer  "quotation_header_id",             limit: 4
    t.integer  "delivery_slip_header_id",         limit: 4
    t.string   "working_middle_item_name",        limit: 255
    t.string   "working_middle_item_short_name",  limit: 255
    t.integer  "working_middle_item_category_id", limit: 4
    t.string   "working_middle_specification",    limit: 255
    t.integer  "working_unit_id",                 limit: 4
    t.string   "working_unit_name",               limit: 255
    t.float    "working_unit_price",              limit: 24
    t.integer  "execution_unit_price",            limit: 4
    t.integer  "material_id",                     limit: 4
    t.string   "working_material_name",           limit: 255
    t.float    "execution_material_unit_price",   limit: 24
    t.float    "material_unit_price",             limit: 24
    t.float    "execution_labor_unit_price",      limit: 24
    t.float    "labor_unit_price",                limit: 24
    t.integer  "labor_unit_price_standard",       limit: 4
    t.float    "labor_productivity_unit",         limit: 24
    t.float    "labor_productivity_unit_total",   limit: 24
    t.integer  "material_cost_total",             limit: 4
    t.integer  "seq",                             limit: 4
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "working_specific_small_items", force: :cascade do |t|
    t.integer  "working_specific_middle_item_id", limit: 4
    t.integer  "working_small_item_id",           limit: 4
    t.string   "working_small_item_code",         limit: 255
    t.string   "working_small_item_name",         limit: 255
    t.float    "unit_price",                      limit: 24
    t.float    "rate",                            limit: 24
    t.integer  "quantity",                        limit: 4
    t.float    "labor_productivity_unit",         limit: 24
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
  end

  create_table "working_subcategories", force: :cascade do |t|
    t.integer  "working_category_id", limit: 4
    t.string   "name",                limit: 255
    t.integer  "seq",                 limit: 4
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
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

  add_foreign_key "account_bank_branch", "account_bank", column: "bank_id", name: "account_bank_branch_bank_id_5343d462_fk_account_bank_id"
  add_foreign_key "account_partner", "account_bank", column: "bank_id", name: "account_partner_bank_id_4b4698ec_fk_account_bank_id"
  add_foreign_key "account_partner", "account_bank_branch", column: "bank_branch_id", name: "account_partne_bank_branch_id_89ec6121_fk_account_bank_branch_id"
  add_foreign_key "account_payment", "account_account_title", column: "account_title_id", name: "account_pa_account_title_id_de8d3cfe_fk_account_account_title_id"
  add_foreign_key "account_payment", "account_partner", column: "partner_id", name: "account_payment_partner_id_efa46d84_fk_account_partner_id"
  add_foreign_key "auth_group_permissions", "auth_group", column: "group_id", name: "auth_group_permissions_group_id_b120cbf9_fk_auth_group_id"
  add_foreign_key "auth_group_permissions", "auth_permission", column: "permission_id", name: "auth_group_permissi_permission_id_84c5c92e_fk_auth_permission_id"
  add_foreign_key "auth_permission", "django_content_type", column: "content_type_id", name: "auth_permissi_content_type_id_2f476e4b_fk_django_content_type_id"
  add_foreign_key "auth_user_groups", "auth_group", column: "group_id", name: "auth_user_groups_group_id_97559544_fk_auth_group_id"
  add_foreign_key "auth_user_groups", "auth_user", column: "user_id", name: "auth_user_groups_user_id_6a12ed8b_fk_auth_user_id"
  add_foreign_key "auth_user_user_permissions", "auth_permission", column: "permission_id", name: "auth_user_user_perm_permission_id_1fbb5f2c_fk_auth_permission_id"
  add_foreign_key "auth_user_user_permissions", "auth_user", column: "user_id", name: "auth_user_user_permissions_user_id_a95ead1b_fk_auth_user_id"
  add_foreign_key "django_admin_log", "auth_user", column: "user_id", name: "django_admin_log_user_id_c564eba6_fk_auth_user_id"
  add_foreign_key "django_admin_log", "django_content_type", column: "content_type_id", name: "django_admin__content_type_id_c4bce8eb_fk_django_content_type_id"
end
