require 'test_helper'

class MonthlyProfitsControllerTest < ActionController::TestCase
  setup do
    @monthly_profit = monthly_profits(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:monthly_profits)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create monthly_profit" do
    assert_difference('MonthlyProfit.count') do
      post :create, monthly_profit: { expense: @monthly_profit.expense, gross_profit: @monthly_profit.gross_profit, occurred_on: @monthly_profit.occurred_on, repayment: @monthly_profit.repayment }
    end

    assert_redirected_to monthly_profit_path(assigns(:monthly_profit))
  end

  test "should show monthly_profit" do
    get :show, id: @monthly_profit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @monthly_profit
    assert_response :success
  end

  test "should update monthly_profit" do
    patch :update, id: @monthly_profit, monthly_profit: { expense: @monthly_profit.expense, gross_profit: @monthly_profit.gross_profit, occurred_on: @monthly_profit.occurred_on, repayment: @monthly_profit.repayment }
    assert_redirected_to monthly_profit_path(assigns(:monthly_profit))
  end

  test "should destroy monthly_profit" do
    assert_difference('MonthlyProfit.count', -1) do
      delete :destroy, id: @monthly_profit
    end

    assert_redirected_to monthly_profits_path
  end
end
