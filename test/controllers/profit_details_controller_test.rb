require 'test_helper'

class ProfitDetailsControllerTest < ActionController::TestCase
  setup do
    @profit_detail = profit_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:profit_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create profit_detail" do
    assert_difference('ProfitDetail.count') do
      post :create, profit_detail: { cost_id: @profit_detail.cost_id, occurred_on: @profit_detail.occurred_on, table_id: @profit_detail.table_id, table_type_id: @profit_detail.table_type_id }
    end

    assert_redirected_to profit_detail_path(assigns(:profit_detail))
  end

  test "should show profit_detail" do
    get :show, id: @profit_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @profit_detail
    assert_response :success
  end

  test "should update profit_detail" do
    patch :update, id: @profit_detail, profit_detail: { cost_id: @profit_detail.cost_id, occurred_on: @profit_detail.occurred_on, table_id: @profit_detail.table_id, table_type_id: @profit_detail.table_type_id }
    assert_redirected_to profit_detail_path(assigns(:profit_detail))
  end

  test "should destroy profit_detail" do
    assert_difference('ProfitDetail.count', -1) do
      delete :destroy, id: @profit_detail
    end

    assert_redirected_to profit_details_path
  end
end
