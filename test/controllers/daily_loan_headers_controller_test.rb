require 'test_helper'

class DailyLoanHeadersControllerTest < ActionController::TestCase
  setup do
    @daily_loan_header = daily_loan_headers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:daily_loan_headers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create daily_loan_header" do
    assert_difference('DailyLoanHeader.count') do
      post :create, daily_loan_header: { borrow: @daily_loan_header.borrow, lend: @daily_loan_header.lend, occurred_on: @daily_loan_header.occurred_on }
    end

    assert_redirected_to daily_loan_header_path(assigns(:daily_loan_header))
  end

  test "should show daily_loan_header" do
    get :show, id: @daily_loan_header
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @daily_loan_header
    assert_response :success
  end

  test "should update daily_loan_header" do
    patch :update, id: @daily_loan_header, daily_loan_header: { borrow: @daily_loan_header.borrow, lend: @daily_loan_header.lend, occurred_on: @daily_loan_header.occurred_on }
    assert_redirected_to daily_loan_header_path(assigns(:daily_loan_header))
  end

  test "should destroy daily_loan_header" do
    assert_difference('DailyLoanHeader.count', -1) do
      delete :destroy, id: @daily_loan_header
    end

    assert_redirected_to daily_loan_headers_path
  end
end
