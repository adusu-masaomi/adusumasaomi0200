require 'test_helper'

class DailyCashFlowsControllerTest < ActionController::TestCase
  setup do
    @daily_cash_flow = daily_cash_flows(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:daily_cash_flows)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create daily_cash_flow" do
    assert_difference('DailyCashFlow.count') do
      post :create, daily_cash_flow: { balance: @daily_cash_flow.balance, cash_flow_date: @daily_cash_flow.cash_flow_date, completed_flag: @daily_cash_flow.completed_flag, expence: @daily_cash_flow.expence, income: @daily_cash_flow.income, plan_actual_flag: @daily_cash_flow.plan_actual_flag }
    end

    assert_redirected_to daily_cash_flow_path(assigns(:daily_cash_flow))
  end

  test "should show daily_cash_flow" do
    get :show, id: @daily_cash_flow
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @daily_cash_flow
    assert_response :success
  end

  test "should update daily_cash_flow" do
    patch :update, id: @daily_cash_flow, daily_cash_flow: { balance: @daily_cash_flow.balance, cash_flow_date: @daily_cash_flow.cash_flow_date, completed_flag: @daily_cash_flow.completed_flag, expence: @daily_cash_flow.expence, income: @daily_cash_flow.income, plan_actual_flag: @daily_cash_flow.plan_actual_flag }
    assert_redirected_to daily_cash_flow_path(assigns(:daily_cash_flow))
  end

  test "should destroy daily_cash_flow" do
    assert_difference('DailyCashFlow.count', -1) do
      delete :destroy, id: @daily_cash_flow
    end

    assert_redirected_to daily_cash_flows_path
  end
end
