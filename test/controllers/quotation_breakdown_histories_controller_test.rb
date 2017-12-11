require 'test_helper'

class QuotationBreakdownHistoriesControllerTest < ActionController::TestCase
  setup do
    @quotation_breakdown_history = quotation_breakdown_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_breakdown_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_breakdown_history" do
    assert_difference('QuotationBreakdownHistory.count') do
      post :create, quotation_breakdown_history: { construction_type: @quotation_breakdown_history.construction_type, equipment_mounting_flag: @quotation_breakdown_history.equipment_mounting_flag, execution_price: @quotation_breakdown_history.execution_price, execution_quantity: @quotation_breakdown_history.execution_quantity, execution_unit_price: @quotation_breakdown_history.execution_unit_price, labor_cost_flag: @quotation_breakdown_history.labor_cost_flag, labor_productivity_unit: @quotation_breakdown_history.labor_productivity_unit, labor_productivity_unit_total: @quotation_breakdown_history.labor_productivity_unit_total, last_line_number: @quotation_breakdown_history.last_line_number, line_number: @quotation_breakdown_history.line_number, piping_wiring_flag: @quotation_breakdown_history.piping_wiring_flag, quantity: @quotation_breakdown_history.quantity, quotation_header_hisory_id: @quotation_breakdown_history.quotation_header_hisory_id, quotation_items_division_id: @quotation_breakdown_history.quotation_items_division_id, quote_price: @quotation_breakdown_history.quote_price, remarks: @quotation_breakdown_history.remarks, working_large_item_id: @quotation_breakdown_history.working_large_item_id, working_large_item_name: @quotation_breakdown_history.working_large_item_name, working_large_item_short_name: @quotation_breakdown_history.working_large_item_short_name, working_large_specification: @quotation_breakdown_history.working_large_specification, working_unit_id: @quotation_breakdown_history.working_unit_id, working_unit_name: @quotation_breakdown_history.working_unit_name, working_unit_price: @quotation_breakdown_history.working_unit_price }
    end

    assert_redirected_to quotation_breakdown_history_path(assigns(:quotation_breakdown_history))
  end

  test "should show quotation_breakdown_history" do
    get :show, id: @quotation_breakdown_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_breakdown_history
    assert_response :success
  end

  test "should update quotation_breakdown_history" do
    patch :update, id: @quotation_breakdown_history, quotation_breakdown_history: { construction_type: @quotation_breakdown_history.construction_type, equipment_mounting_flag: @quotation_breakdown_history.equipment_mounting_flag, execution_price: @quotation_breakdown_history.execution_price, execution_quantity: @quotation_breakdown_history.execution_quantity, execution_unit_price: @quotation_breakdown_history.execution_unit_price, labor_cost_flag: @quotation_breakdown_history.labor_cost_flag, labor_productivity_unit: @quotation_breakdown_history.labor_productivity_unit, labor_productivity_unit_total: @quotation_breakdown_history.labor_productivity_unit_total, last_line_number: @quotation_breakdown_history.last_line_number, line_number: @quotation_breakdown_history.line_number, piping_wiring_flag: @quotation_breakdown_history.piping_wiring_flag, quantity: @quotation_breakdown_history.quantity, quotation_header_hisory_id: @quotation_breakdown_history.quotation_header_hisory_id, quotation_items_division_id: @quotation_breakdown_history.quotation_items_division_id, quote_price: @quotation_breakdown_history.quote_price, remarks: @quotation_breakdown_history.remarks, working_large_item_id: @quotation_breakdown_history.working_large_item_id, working_large_item_name: @quotation_breakdown_history.working_large_item_name, working_large_item_short_name: @quotation_breakdown_history.working_large_item_short_name, working_large_specification: @quotation_breakdown_history.working_large_specification, working_unit_id: @quotation_breakdown_history.working_unit_id, working_unit_name: @quotation_breakdown_history.working_unit_name, working_unit_price: @quotation_breakdown_history.working_unit_price }
    assert_redirected_to quotation_breakdown_history_path(assigns(:quotation_breakdown_history))
  end

  test "should destroy quotation_breakdown_history" do
    assert_difference('QuotationBreakdownHistory.count', -1) do
      delete :destroy, id: @quotation_breakdown_history
    end

    assert_redirected_to quotation_breakdown_histories_path
  end
end
