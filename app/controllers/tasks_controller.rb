class TasksController < ApplicationController
  
  #ガント編集の際に必要！！
  #protect_from_forgery with: :null_session
  skip_before_action :verify_authenticity_token  

  require 'date'

  @@construction_id = ""
  @@start_date = "" 
  @@end_date = ""
  
  before_action :set_task, only: [:show, :edit, :update, :destroy]
  
  #工事IDをクラス変数へ保存
  before_action :set_construction_info, only: [:index]
  
  #
  #before_action :load_construction_id, only: [:data]
  
  # GET /tasks
  # GET /tasks.json
  def index
    #@tasks = Task.all
    #ransack保持用コード
    query = params[:q]
    query ||= eval(cookies[:recent_search_history].to_s)  	
		
	if params[:move_flag] == "1"
	  #工事一覧画面から遷移した場合
	  construction_id = params[:construction_id]
	  ####
	  
	  query = {"construction_datum_id_eq"=> construction_id }
	  
	  #工事開始・終了日のクエリーを初期セットする
      add_query_to_construction_date(query)
	 
	else
	  #クエリーをパラメータに再セットする（検索かけると遷移用パラメータが消える為）
	  return_query_to_parameters(query)
	end
	 
	#@q = ConstructionDailyReport.ransack(params[:q])  
    #ransack保持用--上記はこれに置き換える
	@q = Task.ransack(query)
     
	#ransack保持用コード
    search_history = {
    value: params[:q],
    expires: 24.hours.from_now
    }
    cookies[:recent_search_history] = search_history if params[:q].present?
    #
	 
	@tasks = @q.result(distinct: true)
    
  end
  
  #クエリーをパラメータへ戻す
  def return_query_to_parameters(query)
    if query.present? && query["construction_datum_id_eq"].present?
      params[:construction_id] = query["construction_datum_id_eq"]
	
	  if query["start_date_gteq(1i)"] != nil?
        params[:start_date] = query["start_date_gteq(1i)"] + "/" + query["start_date_gteq(2i)"] + "/" + query["start_date_gteq(3i)"]
	  end
	
	  if query["end_date_lteq(1i)"] != nil?
	    params[:end_date] = query["end_date_lteq(1i)"] + "/" + query["end_date_lteq(2i)"] + "/" + query["end_date_lteq(3i)"]
	  end
    
      set_construction_info  #クラス変数へも再セット
    end
  end

  #工事開始・終了日のクエリーを初期セットする
  def add_query_to_construction_date(query)
    #開始日がセットされていた場合
    if params[:start_date].present? && params[:start_date] != $CONSTRUCTION_NULL_DATE
      
	  year = params[:start_date][0,4]
	  month = params[:start_date][5,2]
	  day = params[:start_date][8,2]
	  
	  query["start_date_gteq(1i)"] = year
	  query["start_date_gteq(2i)"] = month
	  query["start_date_gteq(3i)"] = day
	  
	end
	#終了日がセットされていた場合
    if params[:end_date].present? && params[:end_date] != $CONSTRUCTION_NULL_DATE
      
	  year = params[:end_date][0,4]
	  month = params[:end_date][5,2]
	  day = params[:end_date][8,2]
	  
	  query["end_date_lteq(1i)"] = year
	  query["end_date_lteq(2i)"] = month
	  query["end_date_lteq(3i)"] = day
	  
	end
    
	#queryを返す
	return query
	
  end
  
  def data
    
	#セッションに保持した工事IDを取得
	#load_construction_id
	
	  #if params[:construction_id].present?
    #  construction_id = params[:construction_id]
    
	if @@construction_id.present?
      construction_id = @@construction_id
	  
	  tasks = Task.where("construction_datum_id = ?", construction_id)
    
	  start_date = @@start_date
	  if start_date.present? && start_date != $CONSTRUCTION_NULL_DATE && start_date != $CONSTRUCTION_QUERY_NULL_DATE
	    
		#SQL側がUTC,railsがTokyoのため、時差を埋める（やや強引であるが・・）
		start_date = start_date.to_datetime.in_time_zone("Tokyo") - 9.hours
		
		tasks = tasks.where("start_date >= ?", start_date)
	  end
	  
	  end_date = @@end_date 
	  #end_date = DateTime.parse(@@end_date)
	  #end_date = @@end_date.to_datetime
	  
	  if end_date.present? && end_date != $CONSTRUCTION_NULL_DATE && end_date != $CONSTRUCTION_QUERY_NULL_DATE
	    
		#SQL側がUTC,railsがTokyoのため、時差を埋める（やや強引であるが・・）
		end_date = end_date.to_datetime.in_time_zone("Tokyo") + 9.hours
		
		tasks = tasks.where("end_date <= ?", end_date  )
		
	  end

      #links = Link.where("construction_datum_id >= ?", construction_id)
      #links = Link.where("construction_datum_id = ?", construction_id)
	  links = Link.all
	else
	  tasks = Task.all
      links = Link.all
	end
	
	
    render :json=>{
              :data => tasks.order(:sortorder).map{|task|{
                          :id => task.id,
                          :text => task.text,
                          :start_date => task.start_date.to_time.to_formatted_s(:db),
                          :duration => task.duration,
                          :progress => task.progress,
                          :sortorder => task.sortorder,
                          :parent => task.parent,
						  :priority => task.priority,
						  :color => task.color
                      }},
              :links => links.map{|link|{
                  :id => link.id,
                  :source => link.source,
                  :target => link.target,
                  :type => link.link_type
              }}
           }
  end

  # GET /tasks/1
  # GET /tasks/1.json
  def show
  end

  # GET /tasks/new
  def new
    @task = Task.new
    #工事一覧画面から遷移した場合
    if params[:move_flag] == "1"
      if params[:construction_id].present?
        construction_id = params[:construction_id]
        @construction_data = ConstructionDatum.where("id >= ?", construction_id)
	  end
    end
  end

  # GET /tasks/1/edit
  def edit
  end

  # POST /tasks
  # POST /tasks.json
  def create
    #進捗、パーセント（整数）で入力されているので、小数点に戻す。
    returnToFloat
  
    #色を取得
	params[:task][:color] = get_color(params[:task][:priority])  
    
    #項目名をマスターへ保存する
    save_content_name
      
    @task = Task.new(task_params)

    respond_to do |format|
      if @task.save
	  
	    #ソート順はひとまずIDをセットする
        task_params = {sortorder: @task.id}
	    @task.update(task_params)
	    
        #format.html { redirect_to @task, notice: 'Task was successfully created.' }
        #format.json { render :show, status: :created, location: @task }
		
       format.html {redirect_to task_path(@task, :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
      else
        format.html { render :new }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end
  
  #追加--ガントより操作した場合
  def add
    #ソート用
	#maxOrder = Task.maximum("sortorder") || 0
	maxOrder = Task.where("construction_datum_id = ?", @@construction_id).maximum("sortorder") || 0
	
	
	#色を取得
	@color = get_color(params["priority"])
	
	#SQL側がUTC,railsがTokyoのため、時差を埋める（やや強引であるが・・）
	if params["start_date"].present? 
          start_date = params["start_date"].to_datetime.in_time_zone("Tokyo") -9.hours
	  start_date = start_date.strftime("%Y-%m-%d %H:%M:%S")
          params["start_date"] = start_date
	end
	
	task = Task.create :text => params["text"], :start_date=> params["start_date"], :duration => params["duration"],
                       :progress => params["progress"], :sortorder => maxOrder + 1, :parent => params["parent"], :priority => params["priority"], 
                       :construction_datum_id => @@construction_id, :color => @color

    render :json => {:tid => task.id}
  end
  
  #優先度により色を返す
  def get_color(priority)
    
	color = nil
  
    if priority.present?
      case priority
	  when "2"
	  #高
	    color = "#F78181"
	  when "3"
	  #低
	    color = "yellow"
	  end
	end
	
	return color
  end
  
  # PATCH/PUT /tasks/1
  # PATCH/PUT /tasks/1.json
  def update
  
    if params[:form_edit_flag] == "1"
	#フォームから編集した場合
      
	  #進捗、パーセント（整数）で入力されているので、小数点に戻す。
      returnToFloat
      
	  #色を取得
	  params[:task][:color] = get_color(params[:task][:priority])
	  
	  #項目名をマスターへ保存する
	  save_content_name
	  
	  
	  
      respond_to do |format|
        if @task.update(task_params)
          #format.html { redirect_to @task, notice: 'Task was successfully updated.' }
          #format.json { render :show, status: :ok, location: @task }
		
		  format.html {redirect_to task_path(@task, :construction_id => params[:construction_id], 
           :move_flag => params[:move_flag])}
        else
          format.html { render :edit }
          format.json { render json: @task.errors, status: :unprocessable_entity }
        end
      end
	else
	#ガントから直接編集した場合。
	  	  
      task = Task.find(params["id"])
      task.text = params["text"]
      

      #SQL側がUTC,railsがTokyoのため、時差を埋める（やや強引であるが・・）
      if params[:start_date].present?  && params[:start_date] != @task.start_date
        start_date = params[:start_date].to_datetime.in_time_zone("Tokyo") -9.hours
	    start_date = start_date.strftime("%Y-%m-%d %H:%M:%S")
        params[:start_date] = start_date
      end
      #if params[:end_date].present?  && params[:end_date] != @task.end_date
      #  end_date = params[:end_date].to_datetime.in_time_zone("Tokyo") + 24.hours
	  #  end_date = end_date.strftime("%Y-%m-%d %H:%M:%S")
      #  params[:end_date] = end_date
      #end 
      ##
      task.start_date = params["start_date"]
	  task.end_date = params["end_date"]
      task.duration = params["duration"]
	  task.priority = params["priority"]
	  
	  #色を取得
	  task.color = get_color(params["priority"])
	  
      
	  #終了日を算出
	  if params["start_date"].present?
	    #start_date_dtm = custom_parse(params["start_date"])
	    #日付型に変換
		start_date_dtm = Date.strptime(params["start_date"], '%Y-%m-%d')
		
		if params["duration"].present?
		  duration = params["duration"].to_i
		  
		  #開始日に日数を加算
		  end_date_dtm = start_date_dtm + (duration -1) 
		 
		  #終了日へセット
		  task.end_date = end_date_dtm
		end
	    
	  end
	  
	  #
	  
      task.progress = params["progress"]
      task.sortorder = params["sortorder"]
      task.parent = params["parent"]
      task.save
	
      
	  #ソート用
	  if(params['target'])
        Task.updateOrder(task.id, params['target'])
      end
		
      render :json => {:status => "ok"}
	end
  end

  # DELETE /tasks/1
  # DELETE /tasks/1.json
  def destroy
    #フォームから編集した場合
    @task.destroy
    respond_to do |format|
      #format.html { redirect_to tasks_url, notice: 'Task was successfully destroyed.' }
      #format.json { head :no_content }
	  format.html {redirect_to tasks_path( :construction_id => params[:construction_id], 
         :move_flag => params[:move_flag])}
    end
  end
  
  #フォームにて、内容をマスター保管する場合
  def save_content_name
    
	if params[:task][:master_insert_flag] == "true"
	  task_content = TaskContent.where("name = ?", params[:task][:text])
	  
	  #工程表項目マスターに未登録の場合のみ、新規登録する。
	  if task_content.blank?
	    
	    task_content_params = {name: params[:task][:text]}
	    @task_content = TaskContent.create(task_content_params)
		
	  end
	  
	end
    
  end
  
  
  #削除--ガントより操作した場合
  def delete
    Task.find(params["id"]).destroy
    render :json => {:status => "ok"}
  end

  #進捗、パーセント（整数）で入力されているので、小数点に戻す。
  def returnToFloat
    
    if params[:task][:progress].present? && params[:task][:progress].to_f > 0
	  params[:task][:progress] = params[:task][:progress].to_f / 100
    else
      params[:task][:progress] = 0
    end
    
  end
  
  # 文字列を日付に変換
  #require 'date'
  
  def custom_parse(str)
    date = nil
    if str && !str.empty? #railsなら、if str.present? を使う
      begin
        date = DateTime.parse(str).to_s
      # parseで処理しきれない場合
      rescue ArgumentError
        formats = ['%Y:%m:%d %H:%M:%S'] # 他の形式が必要になったら、この配列に追加
        formats.each do |format|
          begin
            date = DateTime.strptime(str, format)
            break
          rescue ArgumentError
          end
        end
      end
    end
    return date
  end 

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_task
      @task = Task.find(params[:id])
	  
	  #session[:construction_id] = params[:construction_id]
	  
	  #@construction_name = ""
    end

    def set_construction_info
      #session[:construction_id] = params[:construction_id]
	  
	  @@construction_id = params[:construction_id]
	  @@start_date = params[:start_date]
	  @@end_date = params[:end_date]
	end
   

    # Never trust parameters from the scary internet, only allow the white list through.
    def task_params
      params.require(:task).permit(:construction_datum_id, :text, :start_date, :end_date, :work_start_date, :work_end_date, :duration, :parent, :progress, :sortorder, :priority, :color)
    end
end
