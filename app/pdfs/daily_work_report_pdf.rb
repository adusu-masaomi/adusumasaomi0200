class DailyWorkReportPDF
    
  
  #def self.create daily_work_report
  def self.create construction_daily_reports
     #作業日報PDF発行
 
    #tlfファイルを読み込む
    #report = ThinReports::Report.new(layout: "#{Rails.root}/app/pdfs/daily_work_report_pdf.tlf")
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/daily_work_report_pdf.tlf") 
       
    # 1ページ目を開始
    report.start_new_page
     
    @flag = nil
  
    working_date_saved = nil
    working_details_saved = nil
    #初期化
        
    #$construction_daily_reports.joins(:Staff).joins(:construction_datum).order("working_date, staff_id").each do |construction_daily_report| 
    construction_daily_reports.joins(:Staff).joins(:construction_datum).order("working_date, staff_id").each do |construction_daily_report|
    
      #---見出し---
      page_count = report.page_count.to_s + "頁"
      
      if @flag.nil? 
        @flag = "1"
        report.page.item(:construction_code).value(construction_daily_report.construction_datum.construction_code)
        report.page.item(:construction_name).value(construction_daily_report.construction_datum.construction_name)
      end

      report.list(:default).add_row do |row|
        #
        if (working_date_saved == nil) || (working_date_saved != construction_daily_report.working_date)
          print_working_date = construction_daily_report.working_date
          #row.item(:line_working_date).visible = true
          row.item(:line_working_date).styles(:visible => true)
				   
          #社員〜時間の線
          row.item(:line_working_times).styles(:visible => true)
          row.item(:line_working_times_dot).styles(:visible => false)
        else
          print_working_date = nil
          row.item(:line_working_date).styles(:visible => false)
          #社員〜時間の線
          row.item(:line_working_times_dot).styles(:visible => true)
          row.item(:line_working_times).styles(:visible => false)
          #row.item(:line_working_date).visible = false
        end
        
        working_date_saved = construction_daily_report.working_date
        #
        #作業内容（同じものなら印刷しない）
        if (working_details_saved == nil) || (working_details_saved != construction_daily_report.working_details)
          print_working_details = construction_daily_report.working_details
          row.item(:line_working_details).styles(:visible => true)
        else
          print_working_details = nil
          row.item(:line_working_details).styles(:visible => false)
        end
        
        working_details_saved = construction_daily_report.working_details
        #
        #時間表示のフォーマット
        start_time_1 = construction_daily_report.start_time_1.strftime("%H:%M")
        from_to_1 = "〜"
        end_time_1 = construction_daily_report.end_time_1.strftime("%H:%M")
      
        start_time_2 = nil
        from_to_2 = nil
        end_time_2 = nil
        if construction_daily_report.start_time_2.strftime("%H:%M") != "00:00" ||
          construction_daily_report.end_time_2.strftime("%H:%M") != "00:00"
          start_time_2 = construction_daily_report.start_time_2.strftime("%H:%M")
          from_to_2 = "〜"
          end_time_2 = construction_daily_report.end_time_2.strftime("%H:%M")
        end
        #
        #最終の横線
        row.item(:line_last).styles(:visible => false)
      
        row.values working_date: print_working_date, 
              staff_name: construction_daily_report.Staff.staff_name, 
              start_time_1: start_time_1,
              from_to_1: from_to_1, 
              end_time_1: end_time_1,
              start_time_2: start_time_2,
              from_to_2: from_to_2, 
              end_time_2: end_time_2,
              working_details: print_working_details

      end  #report do end
    
    end  #do end
	
    #最終の横線
    report.list(:default).add_row do |row_end|
      row_end.item(:line_working_times_dot).styles(:visible => false)
    end
     
    # ThinReports::Reportを返す
    return report
		
  end  
   
end
   
def setGenGouDate(inDate)
  gengouDate = inDate
  gengouDate = $gengo_name + "#{gengouDate.year - $gengo_minus_ad}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"

  return gengouDate
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
  #円マークをつける
  if @num  == "0"
    @num  = ""
  else
    @num  = "￥" + @num 
  end
end  
