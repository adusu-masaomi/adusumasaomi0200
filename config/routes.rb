Rails.application.routes.draw do
  resources :working_small_items
  resources :quotation_details_histories
  resources :quotation_details_histories
  resources :quotation_breakdown_histories
  resources :quotation_header_histories
  resources :contacts
  resources :stocktakes
  resources :business_holidays
  resources :inventories
  resources :inventory_histories
  resources :inventory_histories
  resources :delivery_slip_detail_middle_classifications
  resources :invoice_detail_middle_classifications
  resources :invoice_detail_middle_classifications
  resources :working_middle_items
  
  
  #resources :working_middle_items do
  #  post :sort, on: :collection
  #end
  resources :working_large_items
  resources :working_units
  resources :delivery_slip_detail_large_classifications
  resources :invoice_detail_large_classifications
  resources :working_units
  resources :delivery_slip_headers
  resources :invoice_headers
  #resources :purchase_order_histories
  resources :purchase_order_histories do
    collection do
      get :get_data
    end
  #   collection do
  #    get :send_email
  end
  
  #map.resources :working_middle_items, :collection => {:reorder => :post}
  
  
  resources :orders
  resources :working_safety_matters
  resources :quotation_items_divisions
  resources :items_divisions
  resources :quotation_detail_middle_classifications
  resources :quotation_middle_items
  resources :quotation_units
  resources :quotation_large_items
  resources :quotation_detail_large_classifications
  resources :quotation_detail_large_classifications
  resources :quotation_detail_large_classifications
  resources :quotation_detail_large_classifications
  resources :quotation_large_classification_details
  resources :quotation_large_classification_details
  resources :quotation_headers
  get '/adusu/session/index'
  
  #get 'purchase_order_data' => 'purchase_order_data#index'
  #get 'purchase_order_data2'
  resources :purchase_order_data2, :controller=>"purchase_order_data2"
  
  resources :users
  resources :construction_costs
  resources :affiliations
  resources :construction_daily_reports
  resources :staffs
  resources :purchase_unit_prices
  resources :purchase_order_data
  #resources :purchase_order_data do
  #  member do
  #    get :send_email
  #  end
  #   collection do
  #    get :send_email
  #end
  #end
  
  resources :purchase_division_masters
  #resources :construction_data
  resources :purchase_divisions
  resources :unit_masters
  resources :maker_masters
  resources :material_masters
  resources :material_masters
  resources :customer_masters
  #resources :supplier_masters
  #resources :construction_data
  resources :construction_data do
    #collection do
    member do
      get :edit2
      patch :update_and_pdf
	end
  end
  
  resources :purchase_data
  
  resources :supplier_masters do
    get :autocomplete_supplier_master_supplier_name, :on => :collection
  end

  resources :session, path: "login", only: [:index, :create] do
    collection do
      delete  '/', to: "session#delete"
    end
  end
   
  #get "construction_data/edit2" => 'construction_data#edit2'
  #
  #get 'construction_data' => 'construction_data#index'
  #get 'construction_data/:id' => 'construction_data#show'
  #get 'construction_data/new' => 'construction_data#new'
  #get 'construction_data/:id/edit' => 'construction_data#edit'
  #get 'construction_data/:id/edit2' => 'construction_data#edit2'
  #post 'construction_data' => 'construction_data#create'
  #patch 'construction_data/:id' => 'construction_data#update'
  #delete 'construction_data/:id' => 'construction_data#destroy'
  #

  #

 
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase
  # get "main_menu/menu0"
  
  get "system/index"
  
  # root :to => 'main_menu'
  
  get '/purchase_datum' => "purchase_data#index"
  # ajax
  
  #インデックスのdrag&dropによるソート用
  post '/working_middle_itemz/reorder' => 'working_middle_items#reorder'
  post '/working_large_itemz/reorder' => 'working_large_items#reorder'
  #add170421
  post '/working_unitz/reorder' => 'working_units#reorder'
  post '/quotation_detail_large_classificationz/reorder' => 'quotation_detail_large_classifications#reorder'
  post '/quotation_breakdown_historiez/reorder' => 'quotation_breakdown_histories#reorder'
  post '/quotation_detail_middle_classificationz/reorder' => 'quotation_detail_middle_classifications#reorder'
  post '/quotation_details_historiez/reorder' => 'quotation_details_histories#reorder'
  post '/delivery_slip_detail_large_classificationz/reorder' => 'delivery_slip_detail_large_classifications#reorder'
  post '/delivery_slip_detail_middle_classificationz/reorder' => 'delivery_slip_detail_middle_classifications#reorder'
  post '/invoice_detail_large_classificationz/reorder' => 'invoice_detail_large_classifications#reorder'
  post '/invoice_detail_middle_classificationz/reorder' => 'invoice_detail_middle_classifications#reorder'
  #
  
  get '/purchase_datum/unit_price_select' => 'purchase_data#unit_price_select'
  get '/purchase_datum/list_price_select' => 'purchase_data#list_price_select'
  get '/purchase_datum/maker_select' => 'purchase_data#maker_select'
  get '/purchase_datum/unit_select' => 'purchase_data#unit_select'
  
  get '/purchase_datum/supplier_item_select' => 'purchase_data#supplier_item_select'
  
  #add170226
  get '/purchase_datum/supplier_select' => 'purchase_data#supplier_select'
  #add170428
  get '/purchase_datum/construction_select_on_stocked' => 'purchase_data#construction_select_on_stocked'
  
  get "/purchase_order_historiez/get_data" => 'purchase_order_histories#get_data'
  #161212
  #get "/purchase_order_historiez/check_quantity" => 'purchase_order_histories#check_quantity'
  
  get '/purchase_order_histories_list' => "purchase_order_histories#index2"
  
  #add170624
  #見積履歴一覧への遷移用
  get '/quotation_header_histories_list' => "quotation_header_histories#index"
  
  #add161128
  get "/purchase_order_historiez/email_select" => 'purchase_order_histories#email_select'
  #add170212
  get "/purchase_order_historiez/material_select" => 'purchase_order_histories#material_select'
  
  #add170722
  get "/purchase_order_historiez/set_sequence" => 'purchase_order_histories#set_sequence'
  
  get '/purchase_order_datum/material_select' => 'purchase_order_data2#material_select'
  get '/construction_datum/working_safety_matter_name_select' => 'construction_data#working_safety_matter_name_select'
  get '/purchase_order_datum/get_last_number_select' => 'purchase_order_data#get_last_number_select'
  #add161207
  get '/purchase_order_datum/get_alias_name' => 'purchase_order_data#get_alias_name'
  get '/purchase_order_datum/get_email1' => 'purchase_order_data#get_email1'

  get '/construction_dataz/construction_and_customer_select' => 'construction_data#construction_and_customer_select'
  #add170830
  get '/construction_dataz/quotation_header_select' => 'construction_data#quotation_header_select'
  get '/construction_dataz/delivery_slip_header_select' => 'construction_data#delivery_slip_header_select'
  
  get '/construction_daily_reportz' => 'construction_daily_reports#index'
  get '/construction_daily_reportz/start_day_select' => 'construction_daily_reports#start_day_select'
  get '/construction_daily_reportz/end_day_select' => 'construction_daily_reports#end_day_select'
  
  get '/construction_costz/construction_name_select' => 'construction_costs#construction_name_select'
  get '/construction_costz/construction_labor_cost_select' => 'construction_costs#construction_labor_cost_select'
  get '/construction_costz/purchase_order_amount_select' => 'construction_costs#purchase_order_amount_select'
  
  #add170210
  get '/construction_costz/purchase_amount_etc_select' => 'construction_costs#purchase_amount_etc_select'
  get '/construction_costz/purchase_amount_select' => 'construction_costs#purchase_amount_select'

  #add170621
  #見積書履歴保存処理
  get "/quotation_header_historiez/set_history" => 'quotation_header_histories#set_history'

  #get '/quotation_headerz/customer_name_select' => 'quotation_headers#customer_name_select'
  #upd161028
  #見積書一覧D顧客情報
  get '/quotation_headerz/customer_info_select' => 'quotation_headers#customer_info_select'
  
  #add170831
  get '/quotation_headerz/duplicate_quotation_header' => 'quotation_headers#duplicate_quotation_header'

  #  add161003
  # upd170131
  get '/quotation_detail_large_classificationz/working_large_item_select' => 'quotation_detail_large_classifications#working_large_item_select'
  get '/quotation_detail_large_classificationz/working_large_specification_select' => 'quotation_detail_large_classifications#working_large_specification_select'
  #見積書内訳D単位名
  #upd170130
  get '/quotation_detail_large_classificationz/working_unit_name_select' => 'quotation_detail_large_classifications#working_unit_name_select'
  get '/quotation_detail_large_classificationz/working_unit_id_select' => 'quotation_detail_large_classifications#working_unit_id_select'
  
  # upd170131
  get '/quotation_detail_large_classificationz/working_unit_price_select' => 'quotation_detail_large_classifications#working_unit_price_select'
  get '/quotation_detail_large_classificationz/execution_unit_price_select' => 'quotation_detail_large_classifications#execution_unit_price_select'
  #歩掛
  get '/quotation_detail_large_classificationz/labor_productivity_unit_select' => 'quotation_detail_large_classifications#labor_productivity_unit_select'
  #歩掛計
  get '/quotation_detail_large_classificationz/labor_productivity_unit_total_select' => 'quotation_detail_large_classifications#labor_productivity_unit_total_select'
  
  #add170524
  #納品書番号用
  get '/invoice_detail_large_classificationz/deliery_slip_header_id_select' => 'invoice_detail_large_classifications#deliery_slip_header_id_select'
  
  #add170308
  #小計用
  get '/quotation_detail_large_classificationz/subtotal_select' => 'quotation_detail_large_classifications#subtotal_select'
  get '/quotation_detail_middle_classificationz/subtotal_select' => 'quotation_detail_middle_classifications#subtotal_select'
  get '/invoice_detail_large_classificationz/subtotal_select' => 'invoice_detail_large_classifications#subtotal_select'
  get '/invoice_detail_middle_classificationz/subtotal_select' => 'invoice_detail_middle_classifications#subtotal_select'
  get '/delivery_slip_detail_large_classificationz/subtotal_select' => 'delivery_slip_detail_large_classifications#subtotal_select'
  get '/delivery_slip_detail_middle_classificationz/subtotal_select' => 'delivery_slip_detail_middle_classifications#subtotal_select'
  
  #add170626
  get '/quotation_breakdown_historiez/subtotal_select' => 'quotation_breakdown_histories#subtotal_select'
  get '/quotation_details_historiez/subtotal_select' => 'quotation_details_histories#subtotal_select'
  
  #add end
  
  #
  #add170223
  #歩掛-配管配線用
  get '/quotation_detail_large_classificationz/LPU_piping_wiring_select' => 'quotation_detail_large_classifications#LPU_piping_wiring_select'
  get '/quotation_detail_middle_classificationz/LPU_piping_wiring_select' => 'quotation_detail_middle_classifications#LPU_piping_wiring_select'
  get '/invoice_detail_large_classificationz/LPU_piping_wiring_select' => 'invoice_detail_large_classifications#LPU_piping_wiring_select'
  get '/invoice_detail_middle_classificationz/LPU_piping_wiring_select' => 'invoice_detail_middle_classifications#LPU_piping_wiring_select'
  get '/delivery_slip_detail_large_classificationz/LPU_piping_wiring_select' => 'delivery_slip_detail_large_classifications#LPU_piping_wiring_select'
  get '/delivery_slip_detail_middle_classificationz/LPU_piping_wiring_select' => 'delivery_slip_detail_middle_classifications#LPU_piping_wiring_select'
  
  #add170626
  get '/quotation_breakdown_historiez/LPU_piping_wiring_select' => 'quotation_breakdown_histories#LPU_piping_wiring_select'
  get '/quotation_details_historiez/LPU_piping_wiring_select' => 'quotation_details_histories#LPU_piping_wiring_select'
  
  #歩掛-機器取付用
  get '/quotation_detail_large_classificationz/LPU_equipment_mounting_select' => 'quotation_detail_large_classifications#LPU_equipment_mounting_select'
  get '/quotation_detail_middle_classificationz/LPU_equipment_mounting_select' => 'quotation_detail_middle_classifications#LPU_equipment_mounting_select'
  get '/invoice_detail_large_classificationz/LPU_equipment_mounting_select' => 'invoice_detail_large_classifications#LPU_equipment_mounting_select'
  get '/invoice_detail_middle_classificationz/LPU_equipment_mounting_select' => 'invoice_detail_middle_classifications#LPU_equipment_mounting_select'
  get '/delivery_slip_detail_large_classificationz/LPU_equipment_mounting_select' => 'delivery_slip_detail_large_classifications#LPU_equipment_mounting_select'
  get '/delivery_slip_detail_middle_classificationz/LPU_equipment_mounting_select' => 'delivery_slip_detail_middle_classifications#LPU_equipment_mounting_select'
  
  #add170626
  get '/quotation_breakdown_historiez/LPU_equipment_mounting_select' => 'quotation_breakdown_histories#LPU_equipment_mounting_select'
  get '/quotation_details_historiez/LPU_equipment_mounting_select' => 'quotation_details_histories#LPU_equipment_mounting_select'
  
  #歩掛-労務費用
  get '/quotation_detail_large_classificationz/LPU_labor_cost_select' => 'quotation_detail_large_classifications#LPU_labor_cost_select'
  get '/quotation_detail_middle_classificationz/LPU_labor_cost_select' => 'quotation_detail_middle_classifications#LPU_labor_cost_select'
  get '/invoice_detail_large_classificationz/LPU_labor_cost_select' => 'invoice_detail_large_classifications#LPU_labor_cost_select'
  get '/invoice_detail_middle_classificationz/LPU_labor_cost_select' => 'invoice_detail_middle_classifications#LPU_labor_cost_select'
  get '/delivery_slip_detail_large_classificationz/LPU_labor_cost_select' => 'delivery_slip_detail_large_classifications#LPU_labor_cost_select'
  get '/delivery_slip_detail_middle_classificationz/LPU_labor_cost_select' => 'delivery_slip_detail_middle_classifications#LPU_labor_cost_select'
  #add end
  
  #add170626
  get '/quotation_breakdown_historiez/LPU_labor_cost_select' => 'quotation_breakdown_histories#LPU_labor_cost_select'
  get '/quotation_details_historiez/LPU_labor_cost_select' => 'quotation_details_histories#LPU_labor_cost_select'
  
  ###
  #請求書見出D関連
  get '/invoice_headerz/customer_info_select' => 'invoice_headers#customer_info_select'
  #請求書内訳D関連
  get '/invoice_detail_large_classificationz/working_large_item_select' => 'invoice_detail_large_classifications#working_large_item_select'
  get '/invoice_detail_large_classificationz/working_large_specification_select' => 'invoice_detail_large_classifications#working_large_specification_select'
  #見積書内訳D単位名
  get '/invoice_detail_large_classificationz/working_unit_name_select' => 'invoice_detail_large_classifications#working_unit_name_select'
  get '/invoice_detail_large_classificationz/working_unit_id_select' => 'invoice_detail_large_classifications#working_unit_id_select'
  get '/invoice_detail_large_classificationz/working_unit_price_select' => 'invoice_detail_large_classifications#working_unit_price_select'
  get '/invoice_detail_large_classificationz/execution_unit_price_select' => 'invoice_detail_large_classifications#execution_unit_price_select'
  #歩掛
  get '/invoice_detail_large_classificationz/labor_productivity_unit_select' => 'invoice_detail_large_classifications#labor_productivity_unit_select'
  #歩掛計
  get '/invoice_detail_large_classificationz/labor_productivity_unit_total_select' => 'invoice_detail_large_classifications#labor_productivity_unit_total_select'
  #add170203
  ###
  #納品書見出D関連
  get '/delivery_slip_headerz/customer_info_select' => 'delivery_slip_headers#customer_info_select'
  #納品書内訳D関連
  get '/delivery_slip_detail_large_classificationz/working_large_item_select' => 'delivery_slip_detail_large_classifications#working_large_item_select'
  get '/delivery_slip_detail_large_classificationz/working_large_specification_select' => 'delivery_slip_detail_large_classifications#working_large_specification_select'
  #納品書内訳D単位名
  get '/delivery_slip_detail_large_classificationz/working_unit_name_select' => 'delivery_slip_detail_large_classifications#working_unit_name_select'
  get '/delivery_slip_detail_large_classificationz/working_unit_id_select' => 'delivery_slip_detail_large_classifications#working_unit_id_select'
  get '/delivery_slip_detail_large_classificationz/working_unit_price_select' => 'delivery_slip_detail_large_classifications#working_unit_price_select'
  get '/delivery_slip_detail_large_classificationz/execution_unit_price_select' => 'delivery_slip_detail_large_classifications#execution_unit_price_select'
  #歩掛
  get '/delivery_slip_detail_large_classificationz/labor_productivity_unit_select' => 'delivery_slip_detail_large_classifications#labor_productivity_unit_select'
  #歩掛計
  get '/delivery_slip_detail_large_classificationz/labor_productivity_unit_total_select' => 'delivery_slip_detail_large_classifications#labor_productivity_unit_total_select'
  ###
  
  #見積明細D,見積内訳M連動用
  get '/quotation_detail_middle_classificationz/working_middle_item_select' => 'quotation_detail_middle_classifications#working_middle_item_select'
  get '/quotation_detail_middle_classificationz/working_middle_specification_select' => 'quotation_detail_middle_classifications#working_middle_specification_select'
  #見積書明細D単位ID
  get '/quotation_detail_middle_classificationz/working_unit_id_select' => 'quotation_detail_middle_classifications#working_unit_id_select'
  #見積書明細D単位名
  get '/quotation_detail_middle_classificationz/working_unit_name_select' => 'quotation_detail_middle_classifications#working_unit_name_select'
  get '/quotation_detail_middle_classificationz/working_unit_price_select' => 'quotation_detail_middle_classifications#working_unit_price_select'
  get '/quotation_detail_middle_classificationz/execution_unit_price_select' => 'quotation_detail_middle_classifications#execution_unit_price_select'
  get '/quotation_detail_middle_classificationz/material_id_select' => 'quotation_detail_middle_classifications#material_id_select'
  get '/quotation_detail_middle_classificationz/quotation_material_name_select' => 'quotation_detail_middle_classifications#quotation_material_name_select'
  get '/quotation_detail_middle_classificationz/material_unit_price_select' => 'quotation_detail_middle_classifications#material_unit_price_select'
  #労務単価 
  get '/quotation_detail_middle_classificationz/labor_unit_price_select' => 'quotation_detail_middle_classifications#labor_unit_price_select'
  #歩掛
  get '/quotation_detail_middle_classificationz/labor_productivity_unit_select' => 'quotation_detail_middle_classifications#labor_productivity_unit_select'
  #歩掛計
  get '/quotation_detail_middle_classificationz/labor_productivity_unit_total_select' => 'quotation_detail_middle_classifications#labor_productivity_unit_total_select'
  #add170626
  get '/quotation_details_historiez/labor_productivity_unit_total_select' => 'quotation_details_histories#labor_productivity_unit_total_select'
  #使用材料数
  get '/quotation_detail_middle_classificationz/material_quantity_select' => 'quotation_detail_middle_classifications#material_quantity_select'
  #付属品等
  get '/quotation_detail_middle_classificationz/accessory_cost_select' => 'quotation_detail_middle_classifications#accessory_cost_select'
  #材料費等
  get '/quotation_detail_middle_classificationz/material_cost_total_select' => 'quotation_detail_middle_classifications#material_cost_total_select'
  #労務費等
  get '/quotation_detail_middle_classificationz/labor_cost_total_select' => 'quotation_detail_middle_classifications#labor_cost_total_select'
  #その他計
  get '/quotation_detail_middle_classificationz/other_cost_select' => 'quotation_detail_middle_classifications#other_cost_select'
  #材料名(材料Mから)
  get '/quotation_detail_middle_classificationz/m_quotation_material_name_select' => 'quotation_detail_middle_classifications#m_quotation_material_name_select'
  #材料単価(材料Mから)
  get '/quotation_detail_middle_classificationz/m_material_unit_price_select' => 'quotation_detail_middle_classifications#m_material_unit_price_select'
  #見出し→品目プルダウン絞り込み用
  get '/quotation_detail_middle_classificationz/quotation_detail_large_classification_id_select' => 'quotation_detail_middle_classifications#quotation_detail_large_classification_id_select'
  
  #add170203
  ########
  #請求明細D,請求内訳M連動用
  get '/invoice_detail_middle_classificationz/working_middle_item_select' => 'invoice_detail_middle_classifications#working_middle_item_select'
  get '/invoice_detail_middle_classificationz/working_middle_specification_select' => 'invoice_detail_middle_classifications#working_middle_specification_select'
  #請求明細D-単位ID
  get '/invoice_detail_middle_classificationz/working_unit_id_select' => 'invoice_detail_middle_classifications#working_unit_id_select'
  #請求明細D-単位名
  get '/invoice_detail_middle_classificationz/working_unit_name_select' => 'invoice_detail_middle_classifications#working_unit_name_select'
  get '/invoice_detail_middle_classificationz/working_unit_price_select' => 'invoice_detail_middle_classifications#working_unit_price_select'
  get '/invoice_detail_middle_classificationz/execution_unit_price_select' => 'invoice_detail_middle_classifications#execution_unit_price_select'
  get '/invoice_detail_middle_classificationz/material_id_select' => 'invoice_detail_middle_classifications#material_id_select'
  get '/invoice_detail_middle_classificationz/working_material_name_select' => 'invoice_detail_middle_classifications#working_material_name_select'
  get '/invoice_detail_middle_classificationz/material_unit_price_select' => 'invoice_detail_middle_classifications#material_unit_price_select'
  #請求明細D-労務単価 
  get '/invoice_detail_middle_classificationz/labor_unit_price_select' => 'invoice_detail_middle_classifications#labor_unit_price_select'
  #請求明細D-歩掛
  get '/invoice_detail_middle_classificationz/labor_productivity_unit_select' => 'invoice_detail_middle_classifications#labor_productivity_unit_select'
  #請求明細D-歩掛計
  get '/invoice_detail_middle_classificationz/labor_productivity_unit_total_select' => 'invoice_detail_middle_classifications#labor_productivity_unit_total_select'
  #請求明細D-使用材料数
  get '/invoice_detail_middle_classificationz/material_quantity_select' => 'invoice_detail_middle_classifications#material_quantity_select'
  #請求明細D-付属品等
  get '/invoice_detail_middle_classificationz/accessory_cost_select' => 'invoice_detail_middle_classifications#accessory_cost_select'
  #請求明細D-材料費等
  get '/invoice_detail_middle_classificationz/material_cost_total_select' => 'invoice_detail_middle_classifications#material_cost_total_select'
  #請求明細D-労務費等
  get '/invoice_detail_middle_classificationz/labor_cost_total_select' => 'invoice_detail_middle_classifications#labor_cost_total_select'
  #請求明細D-その他計
  get '/invoice_detail_middle_classificationz/other_cost_select' => 'invoice_detail_middle_classifications#other_cost_select'
  #請求明細D-材料名(材料Mから)
  get '/invoice_detail_middle_classificationz/m_working_material_name_select' => 'invoice_detail_middle_classifications#m_working_material_name_select'
  #請求明細D-材料単価(材料Mから)
  get '/invoice_detail_middle_classificationz/m_material_unit_price_select' => 'invoice_detail_middle_classifications#m_material_unit_price_select'
  #請求明細D-見出し→品目プルダウン絞り込み用
  get '/invoice_detail_middle_classificationz/invoice_detail_large_classification_id_select' => 'invoice_detail_middle_classifications#invoice_detail_large_classification_id_select'
  ########
  
  #add170203
  ########
  #納品明細D,納品内訳M連動用
  get '/delivery_slip_detail_middle_classificationz/working_middle_item_select' => 'delivery_slip_detail_middle_classifications#working_middle_item_select'
  get '/delivery_slip_detail_middle_classificationz/working_middle_specification_select' => 'delivery_slip_detail_middle_classifications#working_middle_specification_select'
  #納品明細D-単位ID
  get '/delivery_slip_detail_middle_classificationz/working_unit_id_select' => 'delivery_slip_detail_middle_classifications#working_unit_id_select'
  #納品明細D-単位名
  get '/delivery_slip_detail_middle_classificationz/working_unit_name_select' => 'delivery_slip_detail_middle_classifications#working_unit_name_select'
  get '/delivery_slip_detail_middle_classificationz/working_unit_price_select' => 'delivery_slip_detail_middle_classifications#working_unit_price_select'
  get '/delivery_slip_detail_middle_classificationz/execution_unit_price_select' => 'delivery_slip_detail_middle_classifications#execution_unit_price_select'
  get '/delivery_slip_detail_middle_classificationz/material_id_select' => 'delivery_slip_detail_middle_classifications#material_id_select'
  get '/delivery_slip_detail_middle_classificationz/working_material_name_select' => 'delivery_slip_detail_middle_classifications#working_material_name_select'
  get '/delivery_slip_detail_middle_classificationz/material_unit_price_select' => 'delivery_slip_detail_middle_classifications#material_unit_price_select'
  #納品明細D-労務単価 
  get '/delivery_slip_detail_middle_classificationz/labor_unit_price_select' => 'delivery_slip_detail_middle_classifications#labor_unit_price_select'
  #納品明細D-歩掛
  get '/delivery_slip_detail_middle_classificationz/labor_productivity_unit_select' => 'delivery_slip_detail_middle_classifications#labor_productivity_unit_select'
  #納品明細D-歩掛計
  get '/delivery_slip_detail_middle_classificationz/labor_productivity_unit_total_select' => 'delivery_slip_detail_middle_classifications#labor_productivity_unit_total_select'
  #納品明細D-使用材料数
  get '/delivery_slip_detail_middle_classificationz/material_quantity_select' => 'delivery_slip_detail_middle_classifications#material_quantity_select'
  #納品明細D-付属品等
  get '/delivery_slip_detail_middle_classificationz/accessory_cost_select' => 'delivery_slip_detail_middle_classifications#accessory_cost_select'
  #納品明細D-材料費等
  get '/delivery_slip_detail_middle_classificationz/material_cost_total_select' => 'delivery_slip_detail_middle_classifications#material_cost_total_select'
  #納品明細D-労務費等
  get '/delivery_slip_detail_middle_classificationz/labor_cost_total_select' => 'delivery_slip_detail_middle_classifications#labor_cost_total_select'
  #納品明細D-その他計
  get '/delivery_slip_detail_middle_classificationz/other_cost_select' => 'delivery_slip_detail_middle_classifications#other_cost_select'
  #納品明細D-材料名(材料Mから)
  get '/delivery_slip_detail_middle_classificationz/m_working_material_name_select' => 'delivery_slip_detail_middle_classifications#m_working_material_name_select'
  #納品明細D-材料単価(材料Mから)
  get '/delivery_slip_detail_middle_classificationz/m_material_unit_price_select' => 'delivery_slip_detail_middle_classifications#m_material_unit_price_select'
  #納品明細D-見出し→品目プルダウン絞り込み用
  get '/delivery_slip_detail_middle_classificationz/delivery_slip_detail_large_classification_id_select' => 'delivery_slip_detail_middle_classifications#delivery_slip_detail_large_classification_id_select'
  ########
  
  
  #見積内訳M,資材M連動用
  get '/working_middle_itemz/working_material_name_select' => 'working_middle_items#working_material_name_select'
  get '/working_middle_itemz/material_unit_price_select' => 'working_middle_items#material_unit_price_select'
  
  
  #add170712
  get '/working_small_itemz/material_standard_select' => 'working_small_items#material_standard_select'
  
   #会社休日取得用
  get '/business_holidayz/get_business_holiday' => 'business_holidays#get_business_holiday'
  
  #在庫単価取得用 170419
  get '/inventoriez/get_unit_price' => 'inventories#get_unit_price'
  get '/inventoriez/get_quantity' => 'inventories#get_quantity'
  
  #del170707
  #get '/construction_daily_reportz/staff_pay_select' => 'construction_daily_reports#staff_pay_select'
  #add170707
  get '/construction_daily_reportz/staff_information_select' => 'construction_daily_reports#staff_information_select'
  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end
  
  # 保留
  # ExcelReport::Application.routes.draw do
  resources :working_small_items
  resources :quotation_details_histories
  resources :quotation_breakdown_histories
  resources :quotation_header_histories
  resources :contacts
  resources :stocktakes
  resources :business_holidays
  resources :inventories
  resources :inventory_histories
  resources :delivery_slip_detail_middle_classifications
  resources :invoice_detail_middle_classifications
  resources :working_middle_items
  resources :working_large_items
  resources :working_large_items
  resources :working_large_items
  resources :working_large_items
  resources :working_large_items
  resources :working_large_items
  resources :working_large_items
  resources :working_large_items
  resources :working_units
  resources :delivery_slip_detail_large_classifications
  resources :invoice_detail_large_classifications
  resources :delivery_slip_headers
  resources :invoice_headers
  resources :purchase_order_histories
  resources :purchase_order_histories
  resources :orders
  resources :working_safety_matters
  resources :quotation_items_divisions
  resources :quotation_detail_middle_classifications
  resources :quotation_units
  resources :quotation_detail_large_classifications
  resources :quotation_headers
  get 'session/index'

  resources :users
  resources :construction_costs
  resources :affiliations
  #   resources :purchase_data
  #   # resources :products
 
  #   controller :report do
  #     get 'report' => 'report#index', as: :report
  #     get 'report/output', as: :output_report
  #   end
  # end

  #?? forget 
  #resources :purchase_datum do
  #  collection do
  #    get :materials_select
  #  end
  #end


  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
