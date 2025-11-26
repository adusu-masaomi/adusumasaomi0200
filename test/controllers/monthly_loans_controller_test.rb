require 'test_helper'

class MonthlyLoansControllerTest < ActionController::TestCase
  setup do
    @monthly_loan = monthly_loans(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:monthly_loans)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create monthly_loan" do
    assert_difference('MonthlyLoan.count') do
      post :create, monthly_loan: { borrow: @monthly_loan.borrow, is_actual: @monthly_loan.is_actual, lend: @monthly_loan.lend, occur_year_month: @monthly_loan.occur_year_month }
    end

    assert_redirected_to monthly_loan_path(assigns(:monthly_loan))
  end

  test "should show monthly_loan" do
    get :show, id: @monthly_loan
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @monthly_loan
    assert_response :success
  end

  test "should update monthly_loan" do
    patch :update, id: @monthly_loan, monthly_loan: { borrow: @monthly_loan.borrow, is_actual: @monthly_loan.is_actual, lend: @monthly_loan.lend, occur_year_month: @monthly_loan.occur_year_month }
    assert_redirected_to monthly_loan_path(assigns(:monthly_loan))
  end

  test "should destroy monthly_loan" do
    assert_difference('MonthlyLoan.count', -1) do
      delete :destroy, id: @monthly_loan
    end

    assert_redirected_to monthly_loans_path
  end
end
