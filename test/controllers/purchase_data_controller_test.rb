require 'test_helper'

class PurchaseDataControllerTest < ActionController::TestCase
  setup do
    @purchase_datum = purchase_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_datum" do
    assert_difference('PurchaseDatum.count') do
      post :create, purchase_datum: { division_id: @purchase_datum.division_id, list_price: @purchase_datum.list_price, maker_id: @purchase_datum.maker_id, maker_name: @purchase_datum.maker_name, material_code: @purchase_datum.material_code, material_name: @purchase_datum.material_name, order_number: @purchase_datum.order_number, purchase_amount: @purchase_datum.purchase_amount, purchase_date: @purchase_datum.purchase_date, purchase_id: @purchase_datum.purchase_id, purchase_unit_price: @purchase_datum.purchase_unit_price, quantity: @purchase_datum.quantity, unit: @purchase_datum.unit }
    end

    assert_redirected_to purchase_datum_path(assigns(:purchase_datum))
  end

  test "should show purchase_datum" do
    get :show, id: @purchase_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_datum
    assert_response :success
  end

  test "should update purchase_datum" do
    patch :update, id: @purchase_datum, purchase_datum: { division_id: @purchase_datum.division_id, list_price: @purchase_datum.list_price, maker_id: @purchase_datum.maker_id, maker_name: @purchase_datum.maker_name, material_code: @purchase_datum.material_code, material_name: @purchase_datum.material_name, order_number: @purchase_datum.order_number, purchase_amount: @purchase_datum.purchase_amount, purchase_date: @purchase_datum.purchase_date, purchase_id: @purchase_datum.purchase_id, purchase_unit_price: @purchase_datum.purchase_unit_price, quantity: @purchase_datum.quantity, unit: @purchase_datum.unit }
    assert_redirected_to purchase_datum_path(assigns(:purchase_datum))
  end

  test "should destroy purchase_datum" do
    assert_difference('PurchaseDatum.count', -1) do
      delete :destroy, id: @purchase_datum
    end

    assert_redirected_to purchase_data_path
  end
end
