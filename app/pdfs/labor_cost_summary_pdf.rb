class LaborCostSummaryPDF
    
  
  def self.create labor_cost_summary	
	#労務集計表PDF発行
 
       # tlfファイルを読み込む
       #report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/labor_cost_summary_pdf.tlf")
	   report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/labor_cost_summary_pdf.tlf")
       
	  # 1ページ目を開始
      report.start_new_page
      
	  @flag = nil
		 
	  #初期化
	  @working_date = ""
	  @man_month_1 = 0
	  @man_month_2 = 0
	  @man_month_3 = 0
	  @labor_cost_1 = 0
      @labor_cost_2 = 0
	  @labor_cost_3 = 0
	  
	  @man_month_1_total = 0
	  @man_month_2_total = 0
	  @man_month_3_total = 0
	  @labor_cost_1_total = 0
      @labor_cost_2_total = 0
      @labor_cost_3_total = 0
      
      @labor_cost_total = 0
	  
	  #add170303
	  @staff_id = 0
	  
      $construction_daily_reports.order(:working_date).each do |construction_daily_reports| 
	    
		 #---見出し---
         page_count = report.page_count.to_s + "頁"

		 if @flag.nil? 
		 
		    @flag = "1"
		   
		   construction_code = "No."  #工事ナンバーに"No"をつける
		   if construction_daily_reports.construction_datum.construction_code.present?
		     construction_code = construction_code + construction_daily_reports.construction_datum.construction_code
		   end
		   
		   report.page.item(:construction_code).value(construction_code)
		   report.page.item(:construction_name).value(construction_daily_reports.construction_datum.construction_name)
		   #report.page.item(:customer_name).value(construction_costs.construction_datum.CustomerMaster.customer_name)
		 
		   #発行日
		   @gengou = Date.today
		   @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
		   report.page.item(:issue_date).value(@gengou)
			 
		   
		 end
	
	    	
		if @working_date != "" && @working_date != construction_daily_reports.working_date then
	      #明細出力
		  setRow()
		   report.list(:default).add_row do |row|
					 
	       row.values working_date_1: @tmp_working_date_1,
               man_month_1: @tmp_man_month_1,
	           labor_cost_1: @tmp_labor_cost_1,
			   working_date_2: @tmp_working_date_2,
			   man_month_2: @tmp_man_month_2,
	           labor_cost_2: @tmp_labor_cost_2,
			   working_date_3: @tmp_working_date_3,
			   man_month_3: @tmp_man_month_3,
	           labor_cost_3: @tmp_labor_cost_3
	       end 
		  
		   #add170303
		   #トータルへカウント
		   countTotal
		  
	        #値をクリア
	        @man_month_1 = 0
	        @man_month_2 = 0
	        @man_month_3 = 0
	        @labor_cost_1 = 0
            @labor_cost_2 = 0
	        @labor_cost_3 = 0
        else
           #add170303
		  #同一日でも社員が変わった場合。
		  if @working_date != "" && @staff_id != construction_daily_reports.staff_id
		     #トータルへカウント
		     countTotal
		  end
	    end
		
		
		case construction_daily_reports.staff_id
		  when 1 then
		  #薄田さん
		    @man_month_1 += construction_daily_reports.man_month
			@labor_cost_1 += construction_daily_reports.labor_cost
			
			#トータルへもカウント
            #@man_month_1_total += @man_month_1
            #@labor_cost_1_total += @labor_cost_1
			
	      when 2 then
		  #岡戸さん
		    @man_month_2 += construction_daily_reports.man_month
			@labor_cost_2 += construction_daily_reports.labor_cost
            
            #トータルへもカウント
            #@man_month_2_total += @man_month_2
            #@labor_cost_2_total += @labor_cost_2

	  	  when 3 then
		  #村山さん
		    @man_month_3 += construction_daily_reports.man_month
			@labor_cost_3 += construction_daily_reports.labor_cost
            
            #トータルへもカウント
            #@man_month_3_total += @man_month_3
            #@labor_cost_3_total += @labor_cost_3
		end
        
        # 総計をカウント（３人以外は、ないものとする）
        @labor_cost_total += construction_daily_reports.labor_cost
		
		#日付を変数代入
		@working_date = construction_daily_reports.working_date
        #add170303
        #サブルーチン用に社員IDをセットする
        @staff_id = construction_daily_reports.staff_id
         
		 
    end	
	    #明細出力(最終日)
		setRow()
		report.list(:default).add_row do |row|
					 
	   row.values working_date_1: @tmp_working_date_1,
               man_month_1: @tmp_man_month_1,
	           labor_cost_1: @tmp_labor_cost_1,
			   working_date_2: @tmp_working_date_2,
			   man_month_2: @tmp_man_month_2,
	           labor_cost_2: @tmp_labor_cost_2,
			   working_date_3: @tmp_working_date_3,
			   man_month_3: @tmp_man_month_3,
	           labor_cost_3: @tmp_labor_cost_3
	    end 
		
        #トータルへカウント
        countTotal
		
 	    #値をクリア
	    @man_month_1 = 0
	    @man_month_2 = 0
	    @man_month_3 = 0
	    @labor_cost_1 = 0
        @labor_cost_2 = 0
	    @labor_cost_3 = 0
	    
		########
		#最下部の合計欄
        
		#まず見栄えを調整
		adjustSummary
		
		#薄田さん
        if @man_month_1_total != ""
          report.page.item(:man_month_1_total).value(@man_month_1_total)
        end
        if @labor_cost_1_total != ""
          report.page.item(:labor_cost_1_total).value(@labor_cost_1_total)
        end
		#岡戸さん
		if @man_month_2_total != ""
          report.page.item(:man_month_2_total).value(@man_month_2_total)
        end
        if @labor_cost_2_total != ""
          report.page.item(:labor_cost_2_total).value(@labor_cost_2_total)
        end
        #村山さん
        if @man_month_3_total != ""
          report.page.item(:man_month_3_total).value(@man_month_3_total)
        end
        if @labor_cost_3_total != ""
          report.page.item(:labor_cost_3_total).value(@labor_cost_3_total)
        end
		
		#労務費用トータル
		if @labor_cost_total != ""
          report.page.item(:labor_cost_total).value(@labor_cost_total)
        end
		
        #######
		
	    # Thinrs::Reportを返す
        return report
  end  
  
  def self.countTotal
	 case @staff_id
		when 1 
		#薄田さん
		  #トータルへカウント
          @man_month_1_total += @man_month_1
          @labor_cost_1_total += @labor_cost_1
			
	    when 2 
		#岡戸さん
		  #トータルへカウント
          @man_month_2_total += @man_month_2
          @labor_cost_2_total += @labor_cost_2
        when 3 
		#村山さん
		  #トータルへカウント
          @man_month_3_total += @man_month_3
          @labor_cost_3_total += @labor_cost_3
    
     end
  end
  
  def self.adjustSummary
  #小計の見栄えを調整
    if @man_month_1_total == 0
      @man_month_1_total = ""
      @labor_cost_1_total = ""
    else
      @man_month_1_total = sprintf( "%.3f", @man_month_1_total )
      @labor_cost_1_total = "￥" + @labor_cost_1_total.to_s(:delimited)
    end

    if @man_month_2_total == 0
      @man_month_2_total = ""
      @labor_cost_2_total = ""
    else
      @man_month_2_total = sprintf( "%.3f", @man_month_2_total )
      @labor_cost_2_total = "￥" + @labor_cost_2_total.to_s(:delimited)
    end

    if @man_month_3_total == 0
      @man_month_3_total = ""
      @labor_cost_3_total = ""
    else
      @man_month_3_total = sprintf( "%.3f", @man_month_3_total )
      @labor_cost_3_total = "￥" + @labor_cost_3_total.to_s(:delimited)
    end
    
	#労務費トータル計
	if @labor_cost_total == 0
      @labor_cost_total = ""
	else
	  @labor_cost_total = "￥" + @labor_cost_total.to_s(:delimited)
	end
  end
  
  def self.setRow()
    
	@tmp_working_date = "#{@working_date.strftime('%m')}／#{@working_date.strftime('%d')}"
		  
    #0なら非表示にする
    #id=1
	if @man_month_1 == 0
		@tmp_man_month_1 = ""
        @tmp_working_date_1 = ""
	else
	    @tmp_man_month_1 = sprintf( "%.3f", @man_month_1 )
		@tmp_working_date_1 = @tmp_working_date
    end
    if @labor_cost_1 == 0
	    @tmp_labor_cost_1 = ""
    else
	    @tmp_labor_cost_1 = "￥" + @labor_cost_1.to_s(:delimited)
	end
	
	#id=2
	if @man_month_2 == 0
		@tmp_man_month_2 = ""
		@tmp_working_date_2 = ""
    else
	    @tmp_man_month_2 = sprintf( "%.3f", @man_month_2)
		@tmp_working_date_2 = @tmp_working_date
    end
    if @labor_cost_2 == 0
	    @tmp_labor_cost_2 = ""
    else
	    @tmp_labor_cost_2 = "￥" + @labor_cost_2.to_s(:delimited)
	end
	
	#id=3
	if @man_month_3 == 0
		@tmp_man_month_3 = ""
		@tmp_working_date_3 = ""
    else
	    @tmp_man_month_3 = sprintf( "%.3f", @man_month_3 )
		@tmp_working_date_3 = @tmp_working_date
    end
    if @labor_cost_3 == 0
	    @tmp_labor_cost_3 = ""
    else
	    @tmp_labor_cost_3 = "￥" + @labor_cost_3.to_s(:delimited)
	end
	#
	
   
  end
  
 
 
end
   
 
 
    def formatNum()
	    
        if @num.present?
          #整数で四捨五入する
		  @num  = @num.round
		  
		  #桁区切りにする
		  @num  = @num.to_s(:delimited, delimiter: ',')
		else
		  @num  = "0"
        end
		# 円マークをつける
        if @num  == "0"
		  @num  = ""
		else
		  @num  = "￥" + @num 
		end
	end  
