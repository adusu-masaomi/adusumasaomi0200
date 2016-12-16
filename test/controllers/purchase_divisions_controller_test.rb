require 'test_helper'

class PurchaseDivisionsControllerTest < ActionController::TestCase
  setup do
    @purchase_division = purchase_divisions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_divisions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_division" do
    assert_difference('PurchaseDivision.count') do
      post :create, purchase_division: { purchase_division_name: @purchase_division.purchase_division_name }
    end

    assert_redirected_to purchase_division_path(assigns(:purchase_division))
  end

  test "should show purchase_division" do
    get :show, id: @purchase_division
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_division
    assert_response :success
  end

  test "should update purchase_division" do
    patch :update, id: @purchase_division, purchase_division: { purchase_division_name: @purchase_division.purchase_division_name }
    assert_redirected_to purchase_division_path(assigns(:purchase_division))
  end

  test "should destroy purchase_division" do
    assert_difference('PurchaseDivision.count', -1) do
      delete :destroy, id: @purchase_division
    end

    assert_redirected_to purchase_divisions_path
  end
end
