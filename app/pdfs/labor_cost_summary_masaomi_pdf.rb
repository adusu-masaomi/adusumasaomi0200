class LaborCostSummaryMasaomiPDF
    
  
  #def self.create labor_cost_summary_masaomi
  def self.create construction_daily_reports
  #労務集計表(横)PDF発行
 
    #新元号対応 190401
    require "date"
    d_heisei_limit = Date.parse("2019/5/1")
 
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/labor_cost_summary_masaomi_pdf.tlf")
       
	  # 1ページ目を開始
    report.start_new_page
      
	  @flag = nil
   
    #初期化
    @working_date = ""
    @man_month_1 = 0
    @man_month_2 = 0
    @man_month_3 = 0
    @man_month_4 = 0
    @man_month_5 = 0
    @labor_cost_1 = 0
    @labor_cost_2 = 0
    @labor_cost_3 = 0
    @labor_cost_4 = 0
    @labor_cost_5 = 0
	  
    @man_month_1_total = 0
    @man_month_2_total = 0
    @man_month_3_total = 0
	  #
    @man_month_4_total = 0
    @man_month_5_total = 0
	  
    @labor_cost_1_total = 0
    @labor_cost_2_total = 0
    @labor_cost_3_total = 0
    #
    @labor_cost_4_total = 0
    @labor_cost_5_total = 0
  	@labor_cost_total = 0
	  
    @staff_id = 0
	  
    #$construction_daily_reports.order(:working_date).each do |construction_daily_report|
    construction_daily_reports.order(:working_date).each do |construction_daily_report|
 	    
      #---見出し---
      page_count = report.page_count.to_s + "頁"

      if @flag.nil? 
        @flag = "1"
        construction_code = "No."  #工事ナンバーに"No"をつける
        if construction_daily_report.construction_datum.construction_code.present?
          construction_code = construction_code + construction_daily_report.construction_datum.construction_code
        end
    
        report.page.item(:construction_code).value(construction_code)
        report.page.item(:construction_name).value(construction_daily_report.construction_datum.construction_name)
    
        #発行日
        @gengou = Date.today
           
        #元号変わったらここも要変更
        if @gengou >= d_heisei_limit
          #令和
          if @gengou.year - $gengo_minus_ad_2 == 1
          #１年の場合は元年と表記
            @gengou = $gengo_name_2 + "元年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
          else
            @gengou = $gengo_name_2 + "#{@gengou.year - $gengo_minus_ad_2}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
          end
        else
          #平成
          @gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
        end
           
        report.page.item(:issue_date).value(@gengou)
    
      end
	
	    	
      if @working_date != "" && @working_date != construction_daily_report.working_date then
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
	                  labor_cost_3: @tmp_labor_cost_3,
                    working_date_4: @tmp_working_date_4,
                    man_month_4: @tmp_man_month_4,
                    labor_cost_4: @tmp_labor_cost_4
                    #working_date_5: @tmp_working_date_5,
                    #man_month_5: @tmp_man_month_5,
                    #labor_cost_5: @tmp_labor_cost_5
        end 
		    
        #トータルへカウント
        countTotal
		
        #値をクリア
        @man_month_1 = 0
        @man_month_2 = 0
        @man_month_3 = 0
        @man_month_4 = 0
        @man_month_5 = 0
        @labor_cost_1 = 0
        @labor_cost_2 = 0
        @labor_cost_3 = 0
        @labor_cost_4 = 0
        @labor_cost_5 = 0
      else 
        #同一日でも社員が変わった場合。
		    if @working_date != "" && @staff_id != construction_daily_report.staff_id
          #トータルへカウント
          countTotal
        end
      end
		
      case construction_daily_report.staff_id
      when 1 then
      #社長
        @man_month_1 += construction_daily_report.man_month
        @labor_cost_1 += construction_daily_report.labor_cost
      when 2 then
      #岡戸
        @man_month_2 += construction_daily_report.man_month
        @labor_cost_2 += construction_daily_report.labor_cost
      when 3 then
      #村山さん
        @man_month_3 += construction_daily_report.man_month
        @labor_cost_3 += construction_daily_report.labor_cost
      when 4 then
      #高野
        @man_month_4 += construction_daily_report.man_month
        @labor_cost_4 += construction_daily_report.labor_cost
		  end
        
      # 総計をカウント
      @labor_cost_total += construction_daily_report.labor_cost
		
      #日付を変数代入
      @working_date = construction_daily_report.working_date
        
      #サブルーチン用に社員IDをセットする
      @staff_id = construction_daily_report.staff_id
		  #@construction_daily_report = construction_daily_report           
		 
    end	 #do end
    
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
          labor_cost_3: @tmp_labor_cost_3,
          working_date_4: @tmp_working_date_4,
          man_month_4: @tmp_man_month_4,
          labor_cost_4: @tmp_labor_cost_4
          #working_date_5: @tmp_working_date_5,
          #man_month_5: @tmp_man_month_5,
          #labor_cost_5: @tmp_labor_cost_5
    end 

    #トータルへカウント
    countTotal
  
    #値をクリア
    @man_month_1 = 0
    @man_month_2 = 0
    @man_month_3 = 0
    @man_month_4 = 0
    @man_month_5 = 0
    @labor_cost_1 = 0
    @labor_cost_2 = 0
    @labor_cost_3 = 0
    @labor_cost_4 = 0
    @labor_cost_5 = 0
      
    #
    #最下部の合計欄
    #まず見栄えを調整
    adjustSummary
		
    #社長
    if @man_month_1_total != ""
      report.page.item(:man_month_1_total).value(@man_month_1_total)
    end
    if @labor_cost_1_total != ""
      report.page.item(:labor_cost_1_total).value(@labor_cost_1_total)
    end
    #岡戸
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
		
    #高野
    if @man_month_4_total != ""
      report.page.item(:man_month_4_total).value(@man_month_4_total)
    end
    if @labor_cost_4_total != ""
      report.page.item(:labor_cost_4_total).value(@labor_cost_4_total)
    end
    #須戸さん
    #if @man_month_5_total != ""
    #  report.page.item(:man_month_5_total).value(@man_month_5_total)
    #end
    #if @labor_cost_5_total != ""
    #  report.page.item(:labor_cost_5_total).value(@labor_cost_5_total)
    #end
  
    #労務費用トータル
    if @labor_cost_total != ""
      report.page.item(:labor_cost_total).value(@labor_cost_total)
    end
  
    #
    # Thinrs::Reportを返す
    return report
  end  
  
  def self.countTotal
    case @staff_id
    when 1 
    #社長
    #トータルへカウント
      @man_month_1_total += @man_month_1
      @labor_cost_1_total += @labor_cost_1
    when 2 
    #岡戸
    #トータルへカウント
      @man_month_2_total += @man_month_2
      @labor_cost_2_total += @labor_cost_2
    when 3 
    #村山さん
    #トータルへカウント
      @man_month_3_total += @man_month_3
      @labor_cost_3_total += @labor_cost_3
    when 4
    #高野
      #トータルへカウント
      @man_month_4_total += @man_month_4
      @labor_cost_4_total += @labor_cost_4
    end
  end
  
  def self.adjustSummary
  #小計の見栄えを調整
    #社長
    if @man_month_1_total == 0
      @man_month_1_total = ""
      @labor_cost_1_total = ""
    else
      @man_month_1_total = sprintf( "%.3f", @man_month_1_total )
      @labor_cost_1_total = "￥" + @labor_cost_1_total.to_s(:delimited)
    end
    
    #岡戸
    if @man_month_2_total == 0
      @man_month_2_total = ""
      @labor_cost_2_total = ""
    else
      @man_month_2_total = sprintf( "%.3f", @man_month_2_total )
      @labor_cost_2_total = "￥" + @labor_cost_2_total.to_s(:delimited)
    end

    #村山さん
    if @man_month_3_total == 0
      @man_month_3_total = ""
      @labor_cost_3_total = ""
    else
      @man_month_3_total = sprintf( "%.3f", @man_month_3_total )
      @labor_cost_3_total = "￥" + @labor_cost_3_total.to_s(:delimited)
    end
    
    #高野
    if @man_month_4_total == 0
      @man_month_4_total = ""
      @labor_cost_4_total = ""
    else
      @man_month_4_total = sprintf( "%.3f", @man_month_4_total )
      @labor_cost_4_total = "￥" + @labor_cost_4_total.to_s(:delimited)
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
	
    #高野
    if @man_month_4 == 0
      @tmp_man_month_4 = ""
      @tmp_working_date_4 = ""
    else
      @tmp_man_month_4 = sprintf( "%.3f", @man_month_4 )
      @tmp_working_date_4 = @tmp_working_date
    end
    if @labor_cost_4 == 0
      @tmp_labor_cost_4 = ""
    else
      @tmp_labor_cost_4 = "￥" + @labor_cost_4.to_s(:delimited)
    end
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
