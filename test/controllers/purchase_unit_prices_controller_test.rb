require 'test_helper'

class PurchaseUnitPricesControllerTest < ActionController::TestCase
  setup do
    @purchase_unit_price = purchase_unit_prices(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_unit_prices)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_unit_price" do
    assert_difference('PurchaseUnitPrice.count') do
      post :create, purchase_unit_price: { list_price: @purchase_unit_price.list_price, material_id: @purchase_unit_price.material_id, supplier_id: @purchase_unit_price.supplier_id, supplier_material_code: @purchase_unit_price.supplier_material_code, unit_id: @purchase_unit_price.unit_id, unit_price: @purchase_unit_price.unit_price }
    end

    assert_redirected_to purchase_unit_price_path(assigns(:purchase_unit_price))
  end

  test "should show purchase_unit_price" do
    get :show, id: @purchase_unit_price
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_unit_price
    assert_response :success
  end

  test "should update purchase_unit_price" do
    patch :update, id: @purchase_unit_price, purchase_unit_price: { list_price: @purchase_unit_price.list_price, material_id: @purchase_unit_price.material_id, supplier_id: @purchase_unit_price.supplier_id, supplier_material_code: @purchase_unit_price.supplier_material_code, unit_id: @purchase_unit_price.unit_id, unit_price: @purchase_unit_price.unit_price }
    assert_redirected_to purchase_unit_price_path(assigns(:purchase_unit_price))
  end

  test "should destroy purchase_unit_price" do
    assert_difference('PurchaseUnitPrice.count', -1) do
      delete :destroy, id: @purchase_unit_price
    end

    assert_redirected_to purchase_unit_prices_path
  end
end
