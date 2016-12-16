require 'test_helper'

class PurchaseOrderHistoriesControllerTest < ActionController::TestCase
  setup do
    @purchase_order_history = purchase_order_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_order_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_order_history" do
    assert_difference('PurchaseOrderHistory.count') do
      post :create, purchase_order_history: { purchase_order_date: @purchase_order_history.purchase_order_date, purchase_order_datum_id: @purchase_order_history.purchase_order_datum_id, supplier_master_id: @purchase_order_history.supplier_master_id }
    end

    assert_redirected_to purchase_order_history_path(assigns(:purchase_order_history))
  end

  test "should show purchase_order_history" do
    get :show, id: @purchase_order_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_order_history
    assert_response :success
  end

  test "should update purchase_order_history" do
    patch :update, id: @purchase_order_history, purchase_order_history: { purchase_order_date: @purchase_order_history.purchase_order_date, purchase_order_datum_id: @purchase_order_history.purchase_order_datum_id, supplier_master_id: @purchase_order_history.supplier_master_id }
    assert_redirected_to purchase_order_history_path(assigns(:purchase_order_history))
  end

  test "should destroy purchase_order_history" do
    assert_difference('PurchaseOrderHistory.count', -1) do
      delete :destroy, id: @purchase_order_history
    end

    assert_redirected_to purchase_order_histories_path
  end
end
