class WorkingMiddleItemsController < ApplicationController
  before_action :set_working_middle_item, only: [:show, :edit, :update, :destroy, :copy]
  before_action :set_move_flag, only: [:new, :edit]
  
  #新規画面への引継ぎ用クラス変数
  #@@working_category_id = ""
  #@@working_subcategory_id = ""
  
  # GET /working_middle_items
  # GET /working_middle_items.json
  def index
  
    #ページングはコントローラ側で行う（モバイルとの切り分けがあるため）
    page_disp_max_num = 0
    if browser.platform.ios? || browser.platform.android?
      page_disp_max_num = 50
    else
      page_disp_max_num = 200
    end
    #
    
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history_wmi].to_s)
   
    #SEQのソート時、検索したクッキーが上書きされてしまうので、再び連想配列へ加える
    if (cookies[:recent_search_history_wmi].present?  && query.present? && params[:q].nil?) ||
      (params[:q].present? && params[:q][:s].present? && params[:q][:working_category_id_eq].nil?)  
      #クッキー有＆パラメータ無し？ or 
      #パラメータ有＆カテゴリー検索無の状態？
        
      if cookies[:recent_search_history_wmi].present? && query.present?
        if eval(cookies[:recent_search_history_wmi].to_s)["working_category_id_eq"].present?
          query.store("working_category_id_eq", eval(cookies[:recent_search_history_wmi].to_s)["working_category_id_eq"])
        end
        if eval(cookies[:recent_search_history_wmi].to_s)["working_subcategory_id_eq"].present?
          query.store("working_subcategory_id_eq", eval(cookies[:recent_search_history_wmi].to_s)["working_subcategory_id_eq"])
        end
      end
    end
    #
    
    #
    #新規画面にて、検索パラメータを引き継ぐ
    if query.present?
      if query["working_category_id_eq"].present?
        #@@working_category_id = query["working_category_id_eq"]
        session[:working_category_id] = query["working_category_id_eq"]
      end
      if query["working_subcategory_id_eq"].present?
        #@@working_subcategory_id = query["working_subcategory_id_eq"]
        session[:working_subcategory_id] = query["working_subcategory_id_eq"]
      else
        #@@working_subcategory_id = ""
        session[:working_subcategory_id] = ""
      end
    end
    #
    
    #ransack保持用--上記はこれに置き換える
    @q = WorkingMiddleItem.ransack(query)
	
    #ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history_wmi] = search_history if params[:q].present?
    #
  
    @working_middle_items  = @q.result(distinct: true)
    @working_middle_items  = @working_middle_items.page(params[:page]).per(page_disp_max_num)

    #$sort = nil
    session[:sort_working_middle_items] = nil
	
    if query.nil?  
      @working_middle_items  = @working_middle_items.order('seq DESC') 
    else
      if query["s"].present?
        if query["s"] == "seq asc"
          #$sort = "normal"
          session[:sort_working_middle_items] = "normal"
        elsif query["s"] == "seq desc"
          #$sort = "reverse"
          session[:sort_working_middle_items] = "reverse"
        end
      else
        #カテゴリー等のクエリーのみある場合
        @working_middle_items  = @working_middle_items.order('seq ASC') 
      end
    end
	
    if params[:all_sort] == "true"
      #画面のデータを一括で並び替える
      set_seq_reverse
      params[:all_sort] == "false"
    end
    
  end
  
  
  #画面のデータを並び替える
  def set_seq_reverse
    @working_middle_items_after = @working_middle_items  #逆順用のモデル作成
    
    seq = []
    i = 0
    
    @working_middle_items.order("seq").each do |working_middle_item|
      seq[i] = working_middle_item.seq
      i += 1
    end
    
    i = 0
    newSeq = seq.reverse
    
    
    @working_middle_items.order("seq").each do |working_middle_item|
      #更新する
      working_middle_item.update(seq: newSeq[i])
      i += 1
    end
  end
  
  #ドラッグ＆ドロップによる並び替え機能(seqをセットする)
  def reorder
    
    #if $sort == "reverse" 
    if session[:sort_working_middle_items] == "reverse" 
      row = params[:row].split(",").reverse    #ビューの並びが逆のため、パラメータの配列を逆順でセットさせる。
    #elsif $sort.nil? || $sort == "normal"
    elsif session[:sort_working_middle_items].nil? || 
      session[:sort_working_middle_items] == "normal"  
      
      row = params[:row].split(",")
    end
    
    row.each_with_index {|row, i| WorkingMiddleItem.update(row, {:seq => params[:category].to_i + i})}
    render :text => "OK"
  end
  
  # GET /working_middle_items/1
  # GET /working_middle_items/1.json
  def show
  end

  # GET /working_middle_items/new
  def new
    @working_middle_item = WorkingMiddleItem.new
    
    #binding.pry
    
    #呼び出した場合
    #if $working_middle_item.present?
    if session[:working_middle_item_id].present?
      working_middle_item = WorkingMiddleItem.find(session[:working_middle_item_id])
      
      if working_middle_item.present?
        @working_middle_item = working_middle_item
        session[:working_middle_item_id] = nil
      end
      
      #@working_middle_item = $working_middle_item
      #$working_middle_item = nil
    end
    
    #
    if params[:move_flag].blank? 
      
      #検索パラメータの引継ぎ(モーダル時のみ)
      #if @@working_category_id.present?
      if session[:working_category_id].present?
        #@working_middle_item.working_middle_item_category_id = @@working_category_id
        @working_middle_item.working_middle_item_category_id = session[:working_category_id]
      end
      #if @@working_subcategory_id.present?
      if session[:working_subcategory_id].present?
        #@working_middle_item.working_subcategory_id = @@working_subcategory_id
        @working_middle_item.working_subcategory_id = session[:working_subcategory_id]
      end
    
    end
    #
    
    #労務単価の初期値をセットする
    @working_middle_item.labor_unit_price_standard ||= $LABOR_COST
  
  end

  # GET /working_middle_items/1/edit
  def edit
    
    #労務単価の初期値をセットする
    #upd200108 単価変更
    #if @working_middle_item.labor_unit_price_standard.blank? || @working_middle_item.labor_unit_price_standard == 11000
    if @working_middle_item.labor_unit_price_standard.blank? || @working_middle_item.labor_unit_price_standard == 12100
      @working_middle_item.labor_unit_price_standard = $LABOR_COST
    end
  
  end

  # POST /working_middle_items
  # POST /working_middle_items.json
  def create
    
    #明細マスターのパラメータ補正 
    set_params_replenishment
    
    #カテゴリーがなければ新たに作る
    create_category
    
    #表示用の連番を割り振る(新規の場合のみ)
    set_seq
      
    if params[:move_flag].blank?
      #マスター画面からの遷移の場合、モーダルのため、別ルーチンにて処理する。
      create_or_update_modal
    else
      master_insert_flag = false
      #共通マスターへ更新する場合
      if params[:working_middle_item][:master_insert_flag] == "true"
        master_insert_flag = true
      end
      #
      respond_to do |format|
        #品目マスターへの追加・更新
        create_or_update_material
        #共通マスターへの登録（ダイアログ=OKの場合)
        if master_insert_flag == true
          status = nil
          action_flag = params[:working_middle_item][:action_flag]
          if action_flag == "new"
            #新規の場合
            @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
            status = @working_middle_item.save
          elsif action_flag == "edit"
            #更新の場合
            if @working_middle_item.present?
              status = @working_middle_item.update(working_middle_item_params)
            else
            #該当なしの場合（ボタン誤操作など）は、新規登録する
              @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
              status = @working_middle_item.save
            end
          end
        else
          #明細固有マスターへの新規追加(master_insert_flag == false)
          status = create_specific_master
        end
	  
        if status == true
          #手入力用IDの場合は、単位マスタへも登録する。
          set_working_unit
	  
          if master_insert_flag == true   #add171116
            #ソート用のseqにIDをセットする。
            @working_middle_item.update(seq: @working_middle_item.id, working_unit_id: @working_unit.id)
          end
		
          if params[:move_flag].blank?
            format.html { redirect_to @working_middle_item, notice: 'Working middle item was successfully created.' }
            format.json { render :show, status: :created, location: @working_middle_item }
          else
          #見積書画面へ戻る！！
            if params[:move_flag] == "1"
            #見積内訳
              format.html {redirect_to quotation_detail_large_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                  :quotation_header_name => params[:quotation_header_name], :move_flag => params[:move_flag])}
            elsif params[:move_flag] == "2"
            #見積明細
              format.html {redirect_to quotation_detail_middle_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                  :quotation_header_name => params[:quotation_header_name], :quotation_detail_large_classification_id => params[:quotation_detail_large_classification_id],
                  :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
                  :move_flag => params[:move_flag])}
            elsif params[:move_flag] == "3"
            #納品内訳
              format.html {redirect_to delivery_slip_detail_large_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                  :delivery_slip_header_name => params[:delivery_slip_header_name], :move_flag => params[:move_flag])}
            elsif params[:move_flag] == "4"
            #納品明細
              format.html {redirect_to delivery_slip_detail_middle_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                  :delivery_slip_header_name => params[:delivery_slip_header_name], :delivery_slip_detail_large_classification_id => params[:delivery_slip_detail_large_classification_id],
                  :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
                  :move_flag => params[:move_flag])}
            end
          end
        else
            format.html { render :new }
            format.json { render json: @working_middle_item.errors, status: :unprocessable_entity }
        end  #status == true
      end    #do
    end      #params[:move_flag].blank?(else)
  end

  # PATCH/PUT /working_middle_items/1
  # PATCH/PUT /working_middle_items/1.json
  def update
    
    #明細マスターのパラメータ補正 
    set_params_replenishment
    
    #カテゴリーがなければ新たに作る
    create_category
    
    if params[:move_flag].blank?
      #マスター画面からの遷移の場合、モーダルのため、別ルーチンにて処理する。
      create_or_update_modal
    else
    #見積入力等の画面からの遷移の場合。
	    respond_to do |format|
        #品目マスターへの追加・更新
        create_or_update_material
	  
        #共通・固有のどちらを更新するか切り分ける
        status = false
	  
        if params[:working_middle_item][:master_insert_flag] == "true"   
          action_flag = params[:working_middle_item][:action_flag]
	   
          if action_flag == "new"
          #新規登録ボタン押下の場合
		        search_records = WorkingMiddleItem.exists?(:working_middle_item_name => params[:working_middle_item][:working_middle_item_name])
		  
            if search_records.blank?
		          #attributesの"id"のみ抹消する（しないとエラー）
              if params[:working_middle_item][:working_small_items_attributes].present?
                params[:working_middle_item][:working_small_items_attributes].flatten.each do |item|
                  item.delete("id")
                end
              end
		          #
		
              @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
              status = @working_middle_item.save
            else
            #同一の品名ならば、更新とみなす（新規ボタンを押しても更新として扱い）
              status = @working_middle_item.update(working_middle_item_params)
            end
		  
          elsif action_flag == "edit"
          #更新ボタン押下の場合
            status = @working_middle_item.update(working_middle_item_params)
          end
  
        elsif params[:working_middle_item][:master_insert_flag] == "false"   ##false!
        #明細固有マスターへの新規追加
          status = create_specific_master
	      end 
	 
        if status == true
          #手入力用IDの場合は、単位マスタへも登録する。
          set_working_unit
          if params[:move_flag].blank?
          #
          else
            #見積作成画面からの遷移の場合
            if params[:move_flag] == "1"
            #見積内訳
              format.html {redirect_to quotation_detail_large_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                        :quotation_header_name => params[:quotation_header_name], :move_flag => params[:move_flag])}
            elsif params[:move_flag] == "2"
            #見積明細
              format.html {redirect_to quotation_detail_middle_classifications_path(:quotation_header_id => params[:quotation_header_id], 
                :quotation_header_name => params[:quotation_header_name], :quotation_detail_large_classification_id => params[:quotation_detail_large_classification_id],
                :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
                :move_flag => params[:move_flag])}
            elsif params[:move_flag] == "3"
            #納品内訳
		          format.html {redirect_to delivery_slip_detail_large_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                :delivery_slip_header_name => params[:delivery_slip_header_name], :move_flag => params[:move_flag])}
            elsif params[:move_flag] == "4"
            #納品明細
              format.html {redirect_to delivery_slip_detail_middle_classifications_path(:delivery_slip_header_id => params[:delivery_slip_header_id], 
                :delivery_slip_header_name => params[:delivery_slip_header_name], :delivery_slip_detail_large_classification_id => params[:delivery_slip_detail_large_classification_id],
                :working_large_item_name => params[:working_large_item_name], :working_large_specification => params[:working_large_specification],
                :move_flag => params[:move_flag])}
            end
          end
        else
          format.html { render :edit }
          format.json { render json: @working_middle_item.errors, status: :unprocessable_entity }
        end
      end  #end do
    end    #params[:move_flag].blank?(else)
  end
  
  #表示用の連番を割り振る
  def set_seq
  
    sub_category = params[:working_middle_item][:working_middle_item_category_id]
  
    if sub_category.present?
      
      min_seq = WorkingMiddleItem.where(:working_middle_item_category_id => sub_category).minimum(:seq)
      
      if min_seq.present?
        params[:working_middle_item][:seq] = min_seq -1
      else
        params[:working_middle_item][:seq] = 0  #何もない場合、0をセット
      end
    end 
  end
  
  
  #登録・更新処理（モーダル画面より）
  def create_or_update_modal
    #品目マスターへの追加・更新
    create_or_update_material
    
    #共通・固有のどちらを更新するか切り分ける
    status = false

    if params[:working_middle_item][:master_insert_flag] == "true"   
      #action_flag = params[:working_middle_item][:action_flag]
      action_flag = params[:action]
	   
      if action_flag == "update"
      #更新ボタン押下の場合
        status = @working_middle_item.update(working_middle_item_params)
      elsif action_flag == "create"
      #新規ボタン押下の場合
        @working_middle_item = WorkingMiddleItem.new(working_middle_item_params) 
        status = @working_middle_item.save
      end
    end 
	 
    if status == true
      #手入力用IDの場合は、単位マスタへも登録する。
      set_working_unit
	
      if params[:move_flag].blank?
        #マスターメンテ画面からの遷移の場合
        @working_middle_items = WorkingMiddleItem.all
      end
    else
      #
    end
    
  end


  #明細固有マスターへの新規追加（更新はないものとする）
  def create_specific_master
    working_specific_middle_item_params = working_middle_item_params.dup
    
    #working_specific_middle_item_paramsのみにあるフィールド追加・attributesを追加
    working_specific_middle_item_params.store("quotation_header_id", params[:quotation_header_id])
    working_specific_middle_item_params.delete("working_small_items_attributes")
    #
	
    if working_middle_item_params["working_small_items_attributes"].present?
      working_specific_middle_item_params.store("working_specific_small_items_attributes", 
        working_middle_item_params["working_small_items_attributes"])
    end
	
    working_specific_middle_item = WorkingSpecificMiddleItem.new(working_specific_middle_item_params)
    status = working_specific_middle_item.save
    
    return status
  end

  #品目マスターへの追加・更新
  def create_or_update_material
    i = 0
  
    if params[:working_middle_item][:working_small_items_attributes].present?
      
      params[:working_middle_item][:working_small_items_attributes].values.each do |item|
        
        if item[:_destroy] != "1"
    
          @maker_master = MakerMaster.where(:id => item[:maker_master_id]).first
          
          #メーカーを手入力した場合の新規登録
          if @maker_master.nil?
            #名称にID(カテゴリー名が入ってくる--やや強引？)をセット。
            maker_params = {maker_name: item[:maker_master_id] }
            @maker_master = MakerMaster.new(maker_params)
            @maker_master.save!(:validate => false)
                     
            if @maker_master.present?
              #メーカーIDを更新（パラメータ）
              item[:maker_master_id] = @maker_master.id
            end
          end
          #
          
          
          if item[:working_small_item_id] == "1"
          #手入力の場合→新規登録
            #品番品名・メーカーのみ登録。
            material_master_params = {material_code: item[:working_small_item_code], material_name: item[:working_small_item_name], 
                                      maker_id: item[:maker_master_id] }
           
            if item[:working_small_item_code].present?  #add180131 品番がなければマスター反映させない。
              @material_master = MaterialMaster.find_by(material_code: item[:working_small_item_code], 
                        material_name: item[:working_small_item_name])
                   
              if @material_master.blank?  #更新はないものとする
				     
                @material_master = MaterialMaster.new(material_master_params)
                @material_master.save!(:validate => false)
                     
                #新規登録後、作成された資材Mの品番IDをセットする
                item[:working_small_item_id] = @material_master.id
              end
            end
                 
          else
          #手入力以外--特定のデータを更新
            @material_master = MaterialMaster.find(item[:working_small_item_id])
      
            if @material_master.present?
              #品名・メーカーのみ登録とする
              material_master_params = {material_name: item[:working_small_item_name], 
                  maker_id: item[:maker_master_id] }    
              @material_master.update(material_master_params)
            end
          end
        end
    
      end  #end do
    
      i += 1
    
    end    #params[:working_middle_item]~.present?
  end
  
  #カテゴリーがなければ新たに作る
  def create_category
    @working_category = WorkingCategory.where(:id => params[:working_middle_item][:working_middle_item_category_id]).first
    
    if @working_category.nil?
      #名称にID(カテゴリー名が入ってくる--やや強引？)をセット、seqは最大値+1をセットする。
      working_category_params = {category_name: params[:working_middle_item][:working_middle_item_category_id], 
                                 seq: WorkingCategory.maximum(:seq) + 1 }
      @working_category = WorkingCategory.new(working_category_params)
      @working_category.save!(:validate => false)
                     
      if @working_category.present?
        #明細マスターのカテゴリーIDを更新（パラメータ）
        params[:working_middle_item][:working_middle_item_category_id] = @working_category.id
      end
    end
    
    #サブカテゴリーもなければ新たに作る
    create_subcategory
  end
  
  #サブカテゴリーがなければ新たに作る
  def create_subcategory
    @working_subcategory = WorkingSubcategory.where(:id => params[:working_middle_item][:working_subcategory_id], 
                                                    :working_category_id => params[:working_middle_item][:working_middle_item_category_id]).first
    
    if @working_subcategory.nil?
      if WorkingSubcategory.maximum(:seq).present?   
         #名称にID(カテゴリー名が入ってくる--やや強引？)をセット、seqは最大値+1をセットする。
         working_subcategory_params = {working_category_id: params[:working_middle_item][:working_middle_item_category_id],
                 name: params[:working_middle_item][:working_subcategory_id], 
                              seq: WorkingSubcategory.maximum(:seq) + 1 }
         @working_subcategory = WorkingSubcategory.new(working_subcategory_params)
         @working_subcategory.save!(:validate => false)
                     
         if @working_subcategory.present?
           #明細マスターのカテゴリーIDを更新（パラメータ）
           params[:working_middle_item][:working_subcategory_id] = @working_subcategory.id
         end
      end
    end
    
  end
  
  
  #手入力用IDの場合は、単位マスタへも登録する。
  def set_working_unit
    @working_unit = nil
	
    if @working_middle_item.working_unit_id == 1
       
      #既に登録してないかチェック
      @check_unit = WorkingUnit.find_by(working_unit_name: @working_middle_item.working_unit_name)
       
      if @check_unit.nil?
        unit_params = { working_unit_name:  @working_middle_item.working_unit_name }
        @working_unit = WorkingUnit.create(unit_params)
      else
        @working_unit = @check_unit
      end
    else
      @working_unit = WorkingUnit.find(@working_middle_item.working_unit_id)
    end
  
  end

  #パラメータを補充
  def set_params_replenishment
    if params[:working_middle_item][:working_small_items_attributes].present?
	    i = 0
    
      params[:working_middle_item][:working_small_items_attributes].values.each do |item|
        #varidate用のために、本来の箇所から離れたパラメータを再セットする
        item[:material_price] = params[:material_price][i]
        i += 1
      end
		
      #i += 1
    end
  end

  # DELETE /working_middle_items/1
  # DELETE /working_middle_items/1.json
  def destroy
  
    destroy_small_items  #小分類マスターを削除
	
    @working_middle_item.destroy
    respond_to do |format|
      format.html { redirect_to working_middle_items_url, notice: 'Working middle item was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  
  #レコードをコピーする
  def copy
    
    #new_record = @working_middle_item.dup
    @working_middle_item.working_middle_item_name += $STRING_COPY  #わかりやすいように、名前を変更する
    
    new_record = @working_middle_item.deep_clone include: :working_small_items
    
    status = new_record.save
     
    respond_to do |format|
      if status == true
        notice = 'Working middle item was successfully copied.'
      else
        notice = 'Working middle item was unfortunately failed...'
      end
      format.html { redirect_to working_middle_items_url, notice: notice }
      format.json { head :no_content }
    end
  end

  #小分類マスターの削除
  def destroy_small_items
    WorkingSmallItem.where(working_middle_item_id: @working_middle_item.id).destroy_all
  end

  #ajax
  #カテゴリーから該当する商品を取得
  def item_extract
    
    if params[:working_middle_item_category_id] != ""
      #初期値として、”手入力”も選択できるようにする
      @item_extract  = WorkingMiddleItem.where(:id => "1").where("id is NOT NULL").order(:seq).
        pluck("working_middle_item_name, id").to_a
        
      #カテゴリー別のアイテムをセット
      @item_extract  += WorkingMiddleItem.where(:working_middle_item_category_id => params[:working_middle_item_category_id]).
          where("id is NOT NULL").order(:seq).pluck("working_middle_item_name, id").to_a
	
      #初期値として、”手入力”も選択できるようにする
      @item_short_name_extract  = WorkingMiddleItem.where(:id => "1").where("id is NOT NULL").order(:seq).
        pluck("working_middle_item_short_name, id").to_a
      #カテゴリー別のアイテムをセット
      @item_short_name_extract += WorkingMiddleItem.where(:working_middle_item_category_id => 
        params[:working_middle_item_category_id]).where("id is NOT NULL").order(:seq).
        pluck("working_middle_item_short_name, id").to_a
    else
    #カテゴリーがデフォルト（指定なし）の場合
      @item_extract = WorkingMiddleItem.all.order(:seq).pluck("working_middle_item_name, id").to_a
	
      @item_short_name_extract = WorkingMiddleItem.all.order(:seq).pluck("working_middle_item_short_name, id").to_a
    end
  end
  
  #カテゴリー＆サブカテゴリーから該当する商品を取得
  def item_extract_subcategory
    
    if params[:working_middle_item_category_id] != "" && params[:working_subcategory_id] != ""
      
      #初期値として、”手入力”も選択できるようにする
      @item_extract  = WorkingMiddleItem.where(:id => "1").where("id is NOT NULL").order(:seq).
          pluck("working_middle_item_name, id").to_a
      #カテゴリー別のアイテムをセット(以下のみ、”item_extract”ファンクションと異なる。)
      if params[:working_subcategory_id] == "1"
        #サブカテゴリーが１の場合は、サブカテゴリー未選択とみなす。
        @item_extract  += WorkingMiddleItem.where(:working_middle_item_category_id => 
           params[:working_middle_item_category_id]).where("id is NOT NULL").order(:seq).
          pluck("working_middle_item_name, id").to_a
      else
        @item_extract  += WorkingMiddleItem.where(:working_middle_item_category_id => 
           params[:working_middle_item_category_id]).where(:working_subcategory_id => 
           params[:working_subcategory_id]).where("id is NOT NULL").order(:seq).
          pluck("working_middle_item_name, id").to_a
      end
      #
      
      #初期値として、”手入力”も選択できるようにする
      @item_short_name_extract  = WorkingMiddleItem.where(:id => "1").where("id is NOT NULL").order(:seq).
          pluck("working_middle_item_short_name, id").to_a
      #カテゴリー別のアイテムをセット
      if params[:working_subcategory_id] == "1"
        #サブカテゴリーが１の場合は、サブカテゴリー未選択とみなす。
        @item_short_name_extract += WorkingMiddleItem.where(:working_middle_item_category_id => 
          params[:working_middle_item_category_id]).where("id is NOT NULL").order(:seq).
          pluck("working_middle_item_short_name, id").to_a
      else
        @item_short_name_extract += WorkingMiddleItem.where(:working_middle_item_category_id => 
          params[:working_middle_item_category_id]).where(:working_subcategory_id => 
           params[:working_subcategory_id]).where("id is NOT NULL").order(:seq).
          pluck("working_middle_item_short_name, id").to_a
      end
    else
    #カテゴリーがデフォルト（指定なし）の場合
      @item_extract = WorkingMiddleItem.all.order(:seq).to_a.pluck("working_middle_item_name, id")
      @item_short_name_extract = WorkingMiddleItem.all.order(:seq).
        pluck("working_middle_item_short_name, id").to_a
    end

  end
  
   #ajax
  #メーカーから該当する商品を取得
  def working_material_info_select
    #固有マスターより取得
    #$working_middle_item = WorkingMiddleItem.find(params[:id])
    session[:working_middle_item_id] = params[:id]
  end
  
  private
    # Use callbacks to share common setup or constraints between actions.
    def set_working_middle_item
      @working_middle_item = WorkingMiddleItem.find(params[:id])
    end
    
    #移動フラグをセット（ビューに渡す為）
    def set_move_flag
      @move_flag = params[:move_flag]
    end
	
    # Never trust parameters from the scary internet, only allow the white list through.
    def working_middle_item_params
        params.require(:working_middle_item).permit(:working_middle_item_name, :working_middle_item_short_name, :working_middle_item_category_id,
            :working_subcategory_id, :working_middle_specification, :working_unit_id, :working_unit_name, :working_unit_price, :execution_unit_price, :material_id, 
            :working_material_name, :execution_material_unit_price, :material_unit_price, :execution_labor_unit_price, 
            :labor_unit_price, :labor_unit_price_standard, :labor_productivity_unit, :material_quantity,
            :accessory_cost, :material_cost_total, :labor_cost_total, :other_cost, :seq, 
            working_small_items_attributes:   [:id, :working_specific_middle_item_id, :working_small_item_id, :working_small_item_code, :working_small_item_name, 
            :unit_price, :rate, :quantity, :material_price, :maker_master_id, :unit_master_id, :labor_productivity_unit, :_destroy] )
    end
end
