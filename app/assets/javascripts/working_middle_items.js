//--共通用JS--

 //金額計算(材料費)
//function calcMaterialUnitPrice()
function calcWorkingMiddleItemMaterialUnitPrice()
{
   var obj = document.getElementById("execution_material_unit_price").value;
   var num = obj * 1.35;
   //num = floatFormat( num, 4 ) ;
   //upd180316
   num = Math.round(num);   //整数四捨五入とする
   document.getElementById("material_unit_price").value = num;
   var obj2 = document.getElementById("labor_productivity_unit").value;
   //if (obj2 > 0){  del171107 歩掛なくても計算するケース有り
   //金額計算(実行労務単価、労務単価)
     //calcLaborCost();
     calcWorkingMiddleItemLaborCost();
   //}
}

//金額計算(実行労務単価、労務単価)
  //function calcLaborCost()
  function calcWorkingMiddleItemLaborCost()
  {
  
    var obj = document.getElementById("labor_productivity_unit").value;
    //del171107 歩掛なくても計算するケース有り
	if (obj == "") {
	  obj = 0;
	}
	//if (obj > 0) {
	  //実行労務単価
	  num = obj * 11000;
      //num = obj * 12100;   //upd200108
      //upd180316
      num = Math.round(num);   //整数四捨五入とする
      document.getElementById("execution_labor_unit_price").value = num;
      //労務単価
      num = obj * 15000;
      //upd180316
      num = Math.round(num);   //整数四捨五入とする
      document.getElementById("labor_unit_price").value = num;
      
      //実行単価
	  //add171107
	  if (document.getElementById("execution_labor_unit_price").value == ""){
	    document.getElementById("execution_labor_unit_price").value = 0;
      }
	  //
      document.getElementById("execution_unit_price").value =
      parseFloat(document.getElementById("execution_material_unit_price").value) + 
	  parseFloat(document.getElementById("execution_labor_unit_price").value);
	  //単価
	  //add171107
	  if (document.getElementById("labor_unit_price").value == ""){
	    document.getElementById("labor_unit_price").value = 0;
      }
	  document.getElementById("working_unit_price").value =
	  parseFloat(document.getElementById("material_unit_price").value) + parseFloat(document.getElementById("labor_unit_price").value);
	  
	//}
	
    //var num = f.labor_unit_price.value * f.labor_productivity_unit.value;
    //小数点以下を四捨五入
    //f.labor_cost_total.value = Math.round(num);
    
    //if (f.material_cost_total.value > 0){
    //   calcOtherCost(f);
    //}  
  }