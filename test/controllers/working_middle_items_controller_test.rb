require 'test_helper'

class WorkingMiddleItemsControllerTest < ActionController::TestCase
  setup do
    @working_middle_item = working_middle_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_middle_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_middle_item" do
    assert_difference('WorkingMiddleItem.count') do
      post :create, working_middle_item: { accessory_cost: @working_middle_item.accessory_cost, execution_unit_price: @working_middle_item.execution_unit_price, labor_cost_total: @working_middle_item.labor_cost_total, labor_productivity_unit: @working_middle_item.labor_productivity_unit, labor_unit_price: @working_middle_item.labor_unit_price, material_cost_total: @working_middle_item.material_cost_total, material_id: @working_middle_item.material_id, material_quantity: @working_middle_item.material_quantity, material_unit_price: @working_middle_item.material_unit_price, other_cost: @working_middle_item.other_cost, working_material_name: @working_middle_item.working_material_name, working_middle_item_name: @working_middle_item.working_middle_item_name, working_middle_item_short_name: @working_middle_item.working_middle_item_short_name, working_middle_specification: @working_middle_item.working_middle_specification, working_unit_id: @working_middle_item.working_unit_id, working_unit_price: @working_middle_item.working_unit_price }
    end

    assert_redirected_to working_middle_item_path(assigns(:working_middle_item))
  end

  test "should show working_middle_item" do
    get :show, id: @working_middle_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_middle_item
    assert_response :success
  end

  test "should update working_middle_item" do
    patch :update, id: @working_middle_item, working_middle_item: { accessory_cost: @working_middle_item.accessory_cost, execution_unit_price: @working_middle_item.execution_unit_price, labor_cost_total: @working_middle_item.labor_cost_total, labor_productivity_unit: @working_middle_item.labor_productivity_unit, labor_unit_price: @working_middle_item.labor_unit_price, material_cost_total: @working_middle_item.material_cost_total, material_id: @working_middle_item.material_id, material_quantity: @working_middle_item.material_quantity, material_unit_price: @working_middle_item.material_unit_price, other_cost: @working_middle_item.other_cost, working_material_name: @working_middle_item.working_material_name, working_middle_item_name: @working_middle_item.working_middle_item_name, working_middle_item_short_name: @working_middle_item.working_middle_item_short_name, working_middle_specification: @working_middle_item.working_middle_specification, working_unit_id: @working_middle_item.working_unit_id, working_unit_price: @working_middle_item.working_unit_price }
    assert_redirected_to working_middle_item_path(assigns(:working_middle_item))
  end

  test "should destroy working_middle_item" do
    assert_difference('WorkingMiddleItem.count', -1) do
      delete :destroy, id: @working_middle_item
    end

    assert_redirected_to working_middle_items_path
  end
end
