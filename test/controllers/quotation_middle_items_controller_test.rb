require 'test_helper'

class QuotationMiddleItemsControllerTest < ActionController::TestCase
  setup do
    @quotation_middle_item = quotation_middle_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_middle_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_middle_item" do
    assert_difference('QuotationMiddleItem.count') do
      post :create, quotation_middle_item: { accessory_cost: @quotation_middle_item.accessory_cost, labor_cost_total: @quotation_middle_item.labor_cost_total, labor_productivity_unit: @quotation_middle_item.labor_productivity_unit, labor_unit_price: @quotation_middle_item.labor_unit_price, material_cost_total: @quotation_middle_item.material_cost_total, material_unit_price: @quotation_middle_item.material_unit_price, other_cost: @quotation_middle_item.other_cost, quantity: @quotation_middle_item.quantity, quotation_material_id: @quotation_middle_item.quotation_material_id, quotation_middle_item_name: @quotation_middle_item.quotation_middle_item_name, quotation_middle_item_short_name: @quotation_middle_item.quotation_middle_item_short_name, quotation_middle_specification: @quotation_middle_item.quotation_middle_specification, quotation_unit_id: @quotation_middle_item.quotation_unit_id, unit_price: @quotation_middle_item.unit_price }
    end

    assert_redirected_to quotation_middle_item_path(assigns(:quotation_middle_item))
  end

  test "should show quotation_middle_item" do
    get :show, id: @quotation_middle_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_middle_item
    assert_response :success
  end

  test "should update quotation_middle_item" do
    patch :update, id: @quotation_middle_item, quotation_middle_item: { accessory_cost: @quotation_middle_item.accessory_cost, labor_cost_total: @quotation_middle_item.labor_cost_total, labor_productivity_unit: @quotation_middle_item.labor_productivity_unit, labor_unit_price: @quotation_middle_item.labor_unit_price, material_cost_total: @quotation_middle_item.material_cost_total, material_unit_price: @quotation_middle_item.material_unit_price, other_cost: @quotation_middle_item.other_cost, quantity: @quotation_middle_item.quantity, quotation_material_id: @quotation_middle_item.quotation_material_id, quotation_middle_item_name: @quotation_middle_item.quotation_middle_item_name, quotation_middle_item_short_name: @quotation_middle_item.quotation_middle_item_short_name, quotation_middle_specification: @quotation_middle_item.quotation_middle_specification, quotation_unit_id: @quotation_middle_item.quotation_unit_id, unit_price: @quotation_middle_item.unit_price }
    assert_redirected_to quotation_middle_item_path(assigns(:quotation_middle_item))
  end

  test "should destroy quotation_middle_item" do
    assert_difference('QuotationMiddleItem.count', -1) do
      delete :destroy, id: @quotation_middle_item
    end

    assert_redirected_to quotation_middle_items_path
  end
end
