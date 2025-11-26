require 'test_helper'

class DailyLoanDetailsControllerTest < ActionController::TestCase
  setup do
    @daily_loan_detail = daily_loan_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:daily_loan_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create daily_loan_detail" do
    assert_difference('DailyLoanDetail.count') do
      post :create, daily_loan_detail: { amount: @daily_loan_detail.amount, lend_borrow_id: @daily_loan_detail.lend_borrow_id, occurred_on: @daily_loan_detail.occurred_on, source_id: @daily_loan_detail.source_id, summary: @daily_loan_detail.summary, table_id: @daily_loan_detail.table_id, table_type_id: @daily_loan_detail.table_type_id }
    end

    assert_redirected_to daily_loan_detail_path(assigns(:daily_loan_detail))
  end

  test "should show daily_loan_detail" do
    get :show, id: @daily_loan_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @daily_loan_detail
    assert_response :success
  end

  test "should update daily_loan_detail" do
    patch :update, id: @daily_loan_detail, daily_loan_detail: { amount: @daily_loan_detail.amount, lend_borrow_id: @daily_loan_detail.lend_borrow_id, occurred_on: @daily_loan_detail.occurred_on, source_id: @daily_loan_detail.source_id, summary: @daily_loan_detail.summary, table_id: @daily_loan_detail.table_id, table_type_id: @daily_loan_detail.table_type_id }
    assert_redirected_to daily_loan_detail_path(assigns(:daily_loan_detail))
  end

  test "should destroy daily_loan_detail" do
    assert_difference('DailyLoanDetail.count', -1) do
      delete :destroy, id: @daily_loan_detail
    end

    assert_redirected_to daily_loan_details_path
  end
end
