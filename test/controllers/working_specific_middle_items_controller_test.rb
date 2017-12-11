require 'test_helper'

class WorkingSpecificMiddleItemsControllerTest < ActionController::TestCase
  setup do
    @working_specific_middle_item = working_specific_middle_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_specific_middle_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_specific_middle_item" do
    assert_difference('WorkingSpecificMiddleItem.count') do
      post :create, working_specific_middle_item: { delivery_slip_header_id: @working_specific_middle_item.delivery_slip_header_id, execution_labor_unit_prce: @working_specific_middle_item.execution_labor_unit_prce, execution_material_unit_price: @working_specific_middle_item.execution_material_unit_price, execution_unit_price: @working_specific_middle_item.execution_unit_price, labor_productivity_unit: @working_specific_middle_item.labor_productivity_unit, labor_unit_price: @working_specific_middle_item.labor_unit_price, material_id: @working_specific_middle_item.material_id, material_unit_price: @working_specific_middle_item.material_unit_price, quotation_header_id: @working_specific_middle_item.quotation_header_id, seq: @working_specific_middle_item.seq, working_material_name: @working_specific_middle_item.working_material_name, working_middle_item_category_id: @working_specific_middle_item.working_middle_item_category_id, working_middle_item_name: @working_specific_middle_item.working_middle_item_name, working_middle_item_short_name: @working_specific_middle_item.working_middle_item_short_name, working_middle_specification: @working_specific_middle_item.working_middle_specification, working_unit_id: @working_specific_middle_item.working_unit_id, working_unit_price: @working_specific_middle_item.working_unit_price }
    end

    assert_redirected_to working_specific_middle_item_path(assigns(:working_specific_middle_item))
  end

  test "should show working_specific_middle_item" do
    get :show, id: @working_specific_middle_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_specific_middle_item
    assert_response :success
  end

  test "should update working_specific_middle_item" do
    patch :update, id: @working_specific_middle_item, working_specific_middle_item: { delivery_slip_header_id: @working_specific_middle_item.delivery_slip_header_id, execution_labor_unit_prce: @working_specific_middle_item.execution_labor_unit_prce, execution_material_unit_price: @working_specific_middle_item.execution_material_unit_price, execution_unit_price: @working_specific_middle_item.execution_unit_price, labor_productivity_unit: @working_specific_middle_item.labor_productivity_unit, labor_unit_price: @working_specific_middle_item.labor_unit_price, material_id: @working_specific_middle_item.material_id, material_unit_price: @working_specific_middle_item.material_unit_price, quotation_header_id: @working_specific_middle_item.quotation_header_id, seq: @working_specific_middle_item.seq, working_material_name: @working_specific_middle_item.working_material_name, working_middle_item_category_id: @working_specific_middle_item.working_middle_item_category_id, working_middle_item_name: @working_specific_middle_item.working_middle_item_name, working_middle_item_short_name: @working_specific_middle_item.working_middle_item_short_name, working_middle_specification: @working_specific_middle_item.working_middle_specification, working_unit_id: @working_specific_middle_item.working_unit_id, working_unit_price: @working_specific_middle_item.working_unit_price }
    assert_redirected_to working_specific_middle_item_path(assigns(:working_specific_middle_item))
  end

  test "should destroy working_specific_middle_item" do
    assert_difference('WorkingSpecificMiddleItem.count', -1) do
      delete :destroy, id: @working_specific_middle_item
    end

    assert_redirected_to working_specific_middle_items_path
  end
end
