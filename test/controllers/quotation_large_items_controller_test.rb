require 'test_helper'

class QuotationLargeItemsControllerTest < ActionController::TestCase
  setup do
    @quotation_large_item = quotation_large_items(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_large_items)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_large_item" do
    assert_difference('QuotationLargeItem.count') do
      post :create, quotation_large_item: { quotation_large_item_name: @quotation_large_item.quotation_large_item_name, quotation_large_specification: @quotation_large_item.quotation_large_specification }
    end

    assert_redirected_to quotation_large_item_path(assigns(:quotation_large_item))
  end

  test "should show quotation_large_item" do
    get :show, id: @quotation_large_item
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_large_item
    assert_response :success
  end

  test "should update quotation_large_item" do
    patch :update, id: @quotation_large_item, quotation_large_item: { quotation_large_item_name: @quotation_large_item.quotation_large_item_name, quotation_large_specification: @quotation_large_item.quotation_large_specification }
    assert_redirected_to quotation_large_item_path(assigns(:quotation_large_item))
  end

  test "should destroy quotation_large_item" do
    assert_difference('QuotationLargeItem.count', -1) do
      delete :destroy, id: @quotation_large_item
    end

    assert_redirected_to quotation_large_items_path
  end
end
