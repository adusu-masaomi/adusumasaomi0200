require 'test_helper'

class QuotationHeaderHistoriesControllerTest < ActionController::TestCase
  setup do
    @quotation_header_history = quotation_header_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_header_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_header_history" do
    assert_difference('QuotationHeaderHistory.count') do
      post :create, quotation_header_history: { execution_price: @quotation_header_history.execution_price, issue_date: @quotation_header_history.issue_date, last_line_number: @quotation_header_history.last_line_number, net_amount: @quotation_header_history.net_amount, quotation_header_id: @quotation_header_history.quotation_header_id, quote_price: @quotation_header_history.quote_price }
    end

    assert_redirected_to quotation_header_history_path(assigns(:quotation_header_history))
  end

  test "should show quotation_header_history" do
    get :show, id: @quotation_header_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_header_history
    assert_response :success
  end

  test "should update quotation_header_history" do
    patch :update, id: @quotation_header_history, quotation_header_history: { execution_price: @quotation_header_history.execution_price, issue_date: @quotation_header_history.issue_date, last_line_number: @quotation_header_history.last_line_number, net_amount: @quotation_header_history.net_amount, quotation_header_id: @quotation_header_history.quotation_header_id, quote_price: @quotation_header_history.quote_price }
    assert_redirected_to quotation_header_history_path(assigns(:quotation_header_history))
  end

  test "should destroy quotation_header_history" do
    assert_difference('QuotationHeaderHistory.count', -1) do
      delete :destroy, id: @quotation_header_history
    end

    assert_redirected_to quotation_header_histories_path
  end
end
