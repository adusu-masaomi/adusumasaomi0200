require 'test_helper'

class WorkingSmallItemsControllerTest < ActionController::TestCase
  setup do
    @working_small_item = working_small_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_small_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_small_item" do
    assert_difference('WorkingSmallItem.count') do
      post :create, working_small_item: { labor_productivity_unit: @working_small_item.labor_productivity_unit, quantity: @working_small_item.quantity, unit_price: @working_small_item.unit_price, working_middle_item_id: @working_small_item.working_middle_item_id, working_small_item_code: @working_small_item.working_small_item_code, working_small_item_name: @working_small_item.working_small_item_name }
    end

    assert_redirected_to working_small_item_path(assigns(:working_small_item))
  end

  test "should show working_small_item" do
    get :show, id: @working_small_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_small_item
    assert_response :success
  end

  test "should update working_small_item" do
    patch :update, id: @working_small_item, working_small_item: { labor_productivity_unit: @working_small_item.labor_productivity_unit, quantity: @working_small_item.quantity, unit_price: @working_small_item.unit_price, working_middle_item_id: @working_small_item.working_middle_item_id, working_small_item_code: @working_small_item.working_small_item_code, working_small_item_name: @working_small_item.working_small_item_name }
    assert_redirected_to working_small_item_path(assigns(:working_small_item))
  end

  test "should destroy working_small_item" do
    assert_difference('WorkingSmallItem.count', -1) do
      delete :destroy, id: @working_small_item
    end

    assert_redirected_to working_small_items_path
  end
end
