require 'test_helper'

class PurchaseDivisionMastersControllerTest < ActionController::TestCase
  setup do
    @purchase_division_master = purchase_division_masters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:purchase_division_masters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create purchase_division_master" do
    assert_difference('PurchaseDivisionMaster.count') do
      post :create, purchase_division_master: { purchase_division_name: @purchase_division_master.purchase_division_name }
    end

    assert_redirected_to purchase_division_master_path(assigns(:purchase_division_master))
  end

  test "should show purchase_division_master" do
    get :show, id: @purchase_division_master
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @purchase_division_master
    assert_response :success
  end

  test "should update purchase_division_master" do
    patch :update, id: @purchase_division_master, purchase_division_master: { purchase_division_name: @purchase_division_master.purchase_division_name }
    assert_redirected_to purchase_division_master_path(assigns(:purchase_division_master))
  end

  test "should destroy purchase_division_master" do
    assert_difference('PurchaseDivisionMaster.count', -1) do
      delete :destroy, id: @purchase_division_master
    end

    assert_redirected_to purchase_division_masters_path
  end
end
