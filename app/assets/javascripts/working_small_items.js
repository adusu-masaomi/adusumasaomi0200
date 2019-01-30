//--共通用JS--

//アイテム選択後の、各種アイテム情報のセット
//(作業明細フォーム共通用)
//form_flag 1:共通マスター 2:固有マスター
function setWorkingSmallItemDetail(child_index, form_flag){
   
   //共通マスター・固有マスターでコントロール名が違う為、それぞれ名前を取得
   var attributes_name = getWorkingSmallItemAttributesName(form_flag);
   
   //品番をセット
   obj = document.getElementById("material_code_hide");
   var itemIdName = attributes_name + "[" + child_index + "][working_small_item_id]"
   
   var working_small_item_code = "modal_working_small_item_code" + child_index;
   if (document.getElementsByName(itemIdName)[0].value != "1"){
   //手入力品番以外の場合のみ、品番をセット 
     var working_small_item_code = "modal_working_small_item_code" + child_index;
     document.getElementById(working_small_item_code).value = obj.innerText;
   }
   
   //品番有、手入力以外の場合
   if (document.getElementById(working_small_item_code).value != "" && 
      document.getElementsByName(itemIdName)[0].value != "1"){   
          
     //品名をセット
     obj = document.getElementById("material_name_hide");
     var working_small_item_name = "modal_working_small_item_name" + child_index;
     document.getElementById(working_small_item_name).value = obj.innerText;
	 
     //メーカー名をセット add180201
	 obj = document.getElementById("maker_id_hide").textContent;
	 if (obj != null){
	   var index = parseInt(obj);
	   nm = attributes_name + "[" + child_index + "][maker_master_id]"
	   document.getElementsByName(nm)[0].value = index; 
       $(".searchableMaker").trigger("change"); 
	 }
     //単位名をセット add180201
     obj = document.getElementById("unit_master_id_hide").textContent;
     if (obj != null){
       var index = parseInt(obj);
       nm = attributes_name + "[" + child_index + "][unit_master_id]"
       document.getElementsByName(nm)[0].value = index; 
       $(".searchableUnit").trigger("change"); 
     }
        
     //数量をセット
     obj = document.getElementById("quantity_hide");
     var quantity = "modal_quantity" + child_index;
     document.getElementById(quantity).value = obj.innerText;
				 
     //定価をセット
     obj = document.getElementById("unit_price_hide");
     var unit_price = "modal_unit_price" + child_index;
     document.getElementById(unit_price).value = obj.innerText;
	
     //add180726
     //掛け率をセット
	 obj = document.getElementById("rate_hide");
	 var rate = "modal_rate" + child_index;
	 document.getElementById(rate).value = obj.innerText;
    
     //定価の色をセット
     //add180331
     obj = document.getElementById("list_price_color_hide");
     document.getElementById(unit_price).style.color = obj.innerText;
     
     //資材費を算出
     //del171118 基本手入力になる（単純に数量×単価にならない）
     //calcMaterialPrice(child_index, document.getElementById(quantity).value, 
     //                  document.getElementById(unit_price).value);
     //資材費を算出
	 //add180201フィールド化
     obj = document.getElementById("material_price_hide");
	 var material_price = "modal_material_price" + child_index;
	 document.getElementById(material_price).value = obj.innerText;
   }
   
     //歩掛をセット
     obj = document.getElementById("labor_productivity_unit_hide");
     var labor_productivity_unit = "modal_labor_productivity_unit" + child_index;
     document.getElementById(labor_productivity_unit).value = obj.innerText;
				 
     //歩掛り計を算出
     if (document.getElementById(quantity) != undefined){
     //180317 add condition
       calcLaborProductivityUnitTotal(child_index, document.getElementById(quantity).value, 
		document.getElementById(labor_productivity_unit).value);
	 }
        
     //資材費合計を算出
     CalcLaborMaterialCostTotal("modal_material_price");
				
     //歩掛計を算出
     CalcLaborLaborProductivityUnitSum("modal_labor_productivity_unit_total");
				 
     //労務費を算出
     calcLaborCostTotal();
}


function getWorkingSmallItemAttributesName(form_flag){
   var attributes_name = "";
   if (form_flag == 1){
   //共通マスター
     attributes_name = "working_middle_item[working_small_items_attributes]"
   }else if (form_flag == 2)  {
   //固有マスター
     attributes_name = "working_specific_middle_item[working_specific_small_items_attributes]";
   }
   //
   return attributes_name;
}
//掛率の逆算(資材費を入力した場合) add180315
function calcWorkingSmallItemBackRate(child_index, value){
  if (value == "modal_material_price"){
      
    //資材費
    index = "modal_material_price" + child_index;
	material_price = document.getElementById(index).value;
      
    //単価
    index = "modal_unit_price" + child_index;
	unit_price = document.getElementById(index).value;
      
    //数量
    index = "modal_quantity" + child_index;
	quantity = document.getElementById(index).value;
      
    //掛率を求める
    if (quantity != "" && unit_price != "" && material_price != "" && 
        quantity != 0 && unit_price != 0 && material_price != 0) {
      var rateId = "modal_rate" + child_index;
      document.getElementById(rateId).value = material_price / unit_price / quantity;
        
    }
  }
  
}
//資材費のセット
//function calcMaterialPrice(child_index,quantity,unit_price){
function calcWorkingSmallItemMaterialPrice(child_index,quantity,unit_price){

	if (quantity != undefined && unit_price != undefined) {
	  
	  //add171107
	  //全角になっている場合があるので、半角にする
	  quantity = toHalfWidth(quantity);
	  unit_price = toHalfWidth(unit_price);
	  var index = "modal_quantity" + child_index;
	  document.getElementById(index).value = quantity;
	  index = "modal_unit_price" + child_index;
	  document.getElementById(index).value = unit_price;
	  //
	  //add171113
	  //掛け率追加
	  var rateId = "modal_rate" + child_index;   //upd171207
	  rate = document.getElementById(rateId).value;
	  if (rate != ""){
	    rate = toHalfWidth(rate);
	    document.getElementById(rateId).value = rate; //add171118
	  }else{
        //upd180315
	    rate = 0;
	  }
	  //
	  
      var id_material_price = "modal_material_price" + child_index;
      //document.getElementById(material_price).value = quantity * unit_price;
	  //if (document.getElementById(material_price).value == 0 || document.getElementById(material_price).value == ""){
	  //if (unit_price > 0){
      
      
      if (unit_price > 0 && rate > 0){   
      //upd180315 定価&掛率が入力されていなければ、資材費はセットしない。
        var material_price = quantity * rate * unit_price;
        material_price = Math.round(material_price);   //整数四捨五入とする
        
        //document.getElementById(material_price).value = quantity * rate * unit_price;
        if (material_price != undefined){
            document.getElementById(id_material_price).value = material_price;
        }
      } else {
      
        //add180726
        //定価がゼロの場合は、数量＊単価にする  一旦、保留
        //if (document.getElementById(id_material_price).value != undefined && quantity > 0){
        //    var material_price = quantity * material_price_origin;
        //    material_price = Math.round(material_price);   //整数四捨五入とする
        //    if (material_price != undefined){
        //        document.getElementById(id_material_price).value = material_price;
        //    }
        // }
        
      }
    }
}
