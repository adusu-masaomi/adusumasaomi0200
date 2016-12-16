require 'test_helper'

class PurchaseOrderDataControllerTest < ActionController::TestCase
  setup do
    @purchase_order_datum = purchase_order_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_order_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_order_datum" do
    assert_difference('PurchaseOrderDatum.count') do
      post :create, purchase_order_datum: { construction_id: @purchase_order_datum.construction_id, purchase_code: @purchase_order_datum.purchase_code }
    end

    assert_redirected_to purchase_order_datum_path(assigns(:purchase_order_datum))
  end

  test "should show purchase_order_datum" do
    get :show, id: @purchase_order_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_order_datum
    assert_response :success
  end

  test "should update purchase_order_datum" do
    patch :update, id: @purchase_order_datum, purchase_order_datum: { construction_id: @purchase_order_datum.construction_id, purchase_code: @purchase_order_datum.purchase_code }
    assert_redirected_to purchase_order_datum_path(assigns(:purchase_order_datum))
  end

  test "should destroy purchase_order_datum" do
    assert_difference('PurchaseOrderDatum.count', -1) do
      delete :destroy, id: @purchase_order_datum
    end

    assert_redirected_to purchase_order_data_path
  end
end
