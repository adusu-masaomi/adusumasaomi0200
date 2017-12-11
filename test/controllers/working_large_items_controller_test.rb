require 'test_helper'

class WorkingLargeItemsControllerTest < ActionController::TestCase
  setup do
    @working_large_item = working_large_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_large_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_large_item" do
    assert_difference('WorkingLargeItem.count') do
      post :create, working_large_item: { execution_unit_price: @working_large_item.execution_unit_price, labor_productivity_unit: @working_large_item.labor_productivity_unit, labor_productivity_unit_total: @working_large_item.labor_productivity_unit_total, working_large_item_name: @working_large_item.working_large_item_name, working_large_specification: @working_large_item.working_large_specification, working_unit_id: @working_large_item.working_unit_id, working_unit_price: @working_large_item.working_unit_price }
    end

    assert_redirected_to working_large_item_path(assigns(:working_large_item))
  end

  test "should show working_large_item" do
    get :show, id: @working_large_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_large_item
    assert_response :success
  end

  test "should update working_large_item" do
    patch :update, id: @working_large_item, working_large_item: { execution_unit_price: @working_large_item.execution_unit_price, labor_productivity_unit: @working_large_item.labor_productivity_unit, labor_productivity_unit_total: @working_large_item.labor_productivity_unit_total, working_large_item_name: @working_large_item.working_large_item_name, working_large_specification: @working_large_item.working_large_specification, working_unit_id: @working_large_item.working_unit_id, working_unit_price: @working_large_item.working_unit_price }
    assert_redirected_to working_large_item_path(assigns(:working_large_item))
  end

  test "should destroy working_large_item" do
    assert_difference('WorkingLargeItem.count', -1) do
      delete :destroy, id: @working_large_item
    end

    assert_redirected_to working_large_items_path
  end
end
