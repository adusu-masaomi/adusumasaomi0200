require 'test_helper'

class MonthlyBalancesControllerTest < ActionController::TestCase
  setup do
    @monthly_balance = monthly_balances(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:monthly_balances)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create monthly_balance" do
    assert_difference('MonthlyBalance.count') do
      post :create, monthly_balance: { balance_cash: @monthly_balance.balance_cash, balance_daishi_hokuetsu: @monthly_balance.balance_daishi_hokuetsu, balance_sanshin: @monthly_balance.balance_sanshin, year_month: @monthly_balance.year_month }
    end

    assert_redirected_to monthly_balance_path(assigns(:monthly_balance))
  end

  test "should show monthly_balance" do
    get :show, id: @monthly_balance
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @monthly_balance
    assert_response :success
  end

  test "should update monthly_balance" do
    patch :update, id: @monthly_balance, monthly_balance: { balance_cash: @monthly_balance.balance_cash, balance_daishi_hokuetsu: @monthly_balance.balance_daishi_hokuetsu, balance_sanshin: @monthly_balance.balance_sanshin, year_month: @monthly_balance.year_month }
    assert_redirected_to monthly_balance_path(assigns(:monthly_balance))
  end

  test "should destroy monthly_balance" do
    assert_difference('MonthlyBalance.count', -1) do
      delete :destroy, id: @monthly_balance
    end

    assert_redirected_to monthly_balances_path
  end
end
