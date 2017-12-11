require 'test_helper'

class QuotationDetailsHistoriesControllerTest < ActionController::TestCase
  setup do
    @quotation_details_history = quotation_details_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_details_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_details_history" do
    assert_difference('QuotationDetailsHistory.count') do
      post :create, quotation_details_history: { construction_type: @quotation_details_history.construction_type, equipment_mounting_flag: @quotation_details_history.equipment_mounting_flag, execution_price: @quotation_details_history.execution_price, execution_quontity: @quotation_details_history.execution_quontity, execution_unit_price: @quotation_details_history.execution_unit_price, labor_cost_flag: @quotation_details_history.labor_cost_flag, labor_productivity_unit: @quotation_details_history.labor_productivity_unit, labor_productivity_unit_total: @quotation_details_history.labor_productivity_unit_total, line_number: @quotation_details_history.line_number, piping_wiring_flag: @quotation_details_history.piping_wiring_flag, quantity: @quotation_details_history.quantity, quotation_breakdown_history_id: @quotation_details_history.quotation_breakdown_history_id, quotation_header_history_id: @quotation_details_history.quotation_header_history_id, quote_price: @quotation_details_history.quote_price, remarks: @quotation_details_history.remarks, working_middle_item_id: @quotation_details_history.working_middle_item_id, working_middle_item_name: @quotation_details_history.working_middle_item_name, working_middle_item_short_name: @quotation_details_history.working_middle_item_short_name, working_middle_specification: @quotation_details_history.working_middle_specification, working_unit_id: @quotation_details_history.working_unit_id, working_unit_price: @quotation_details_history.working_unit_price }
    end

    assert_redirected_to quotation_details_history_path(assigns(:quotation_details_history))
  end

  test "should show quotation_details_history" do
    get :show, id: @quotation_details_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_details_history
    assert_response :success
  end

  test "should update quotation_details_history" do
    patch :update, id: @quotation_details_history, quotation_details_history: { construction_type: @quotation_details_history.construction_type, equipment_mounting_flag: @quotation_details_history.equipment_mounting_flag, execution_price: @quotation_details_history.execution_price, execution_quontity: @quotation_details_history.execution_quontity, execution_unit_price: @quotation_details_history.execution_unit_price, labor_cost_flag: @quotation_details_history.labor_cost_flag, labor_productivity_unit: @quotation_details_history.labor_productivity_unit, labor_productivity_unit_total: @quotation_details_history.labor_productivity_unit_total, line_number: @quotation_details_history.line_number, piping_wiring_flag: @quotation_details_history.piping_wiring_flag, quantity: @quotation_details_history.quantity, quotation_breakdown_history_id: @quotation_details_history.quotation_breakdown_history_id, quotation_header_history_id: @quotation_details_history.quotation_header_history_id, quote_price: @quotation_details_history.quote_price, remarks: @quotation_details_history.remarks, working_middle_item_id: @quotation_details_history.working_middle_item_id, working_middle_item_name: @quotation_details_history.working_middle_item_name, working_middle_item_short_name: @quotation_details_history.working_middle_item_short_name, working_middle_specification: @quotation_details_history.working_middle_specification, working_unit_id: @quotation_details_history.working_unit_id, working_unit_price: @quotation_details_history.working_unit_price }
    assert_redirected_to quotation_details_history_path(assigns(:quotation_details_history))
  end

  test "should destroy quotation_details_history" do
    assert_difference('QuotationDetailsHistory.count', -1) do
      delete :destroy, id: @quotation_details_history
    end

    assert_redirected_to quotation_details_histories_path
  end
end
