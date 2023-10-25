class ConstructionListPDF
    
  
  def self.create construction_data
	#工事一覧表PDF発行
    #新元号対応 190401
    require "date"
    @d_heisei_limit = Date.parse("2019/5/1")
   
    # tlfファイルを読み込む
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/construction_list_pdf.tlf")
       
    # 1ページ目を開始
    report.start_new_page

    #初期化
    @flag = nil
    
    #$construction_data.order("construction_code desc").each do |construction_datum|
    #upd230418
    construction_data.order("construction_code desc").each do |construction_datum| 
    
      #---見出し---
      page_count = report.page_count.to_s + "頁"
      report.page.item(:page_no).value(page_count)

      #if @flag.nil? 
      #   @flag = "1"
      #end

      if construction_datum.reception_date.present?
        @reception_date = setGenGouDate(construction_datum.reception_date)
        #@gengou = construction_datum.reception_date
        #@gengou = $gengo_name + "#{@gengou.year - $gengo_minus_ad}年#{@gengou.strftime('%-m')}月#{@gengou.strftime('%-d')}日"
      end
  
      report.list(:default).add_row do |row|
      
        billed_flag = false
        if construction_datum.billed_flag != nil && construction_datum.billed_flag > 0
          billed_flag = true
        end
    
        row.values construction_code: construction_datum.construction_code,
                  reception_date: @reception_date,
                  construction_name: construction_datum.construction_name,
                  customer_code: construction_datum.CustomerMaster.id,
                  customer_name: construction_datum.CustomerMaster.customer_name
      
        row.item(:frame).styles(:fill_color => '#F7BE81')  if billed_flag == true
      
        #縦線は再描画させないと描写されない
        row.item(:line_1).styles(:fill_color => '#F7BE81')
        row.item(:line_2).styles(:fill_color => '#F7BE81')
        row.item(:line_3).styles(:fill_color => '#F7BE81')
        row.item(:line_4).styles(:fill_color => '#F7BE81')

      end 
    
    end	
		
    # ThinReports::Reportを返す
    return report
		
  end  
   
end
   
   
def setGenGouDate(inDate)
  gengouDate = inDate
  
  #元号変わったらここも要変更
  if gengouDate >= @d_heisei_limit
  #令和
    if gengouDate.year - $gengo_minus_ad_2 == 1
    #１年の場合は元年と表記
      gengouDate = $gengo_name_2 + "元年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
    else
      gengouDate = $gengo_name_2 + "#{gengouDate.year - $gengo_minus_ad_2}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
    end
  else
  #平成
    gengouDate = $gengo_name + "#{gengouDate.year - $gengo_minus_ad}年#{gengouDate.strftime('%-m')}月#{gengouDate.strftime('%-d')}日"
  end
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
		# 円マークをつける
        if @num  == "0"
		  @num  = ""
		else
		  @num  = "￥" + @num 
		end
	end  
