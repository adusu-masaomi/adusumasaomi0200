require 'test_helper'

class QuotationHeadersControllerTest < ActionController::TestCase
  setup do
    @quotation_header = quotation_headers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_headers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_header" do
    assert_difference('QuotationHeader.count') do
      post :create, quotation_header: { address: @quotation_header.address, construction_datum_id: @quotation_header.construction_datum_id, construction_period: @quotation_header.construction_period, construction_place: @quotation_header.construction_place, contsrutction_name: @quotation_header.contsrutction_name, customer_id: @quotation_header.customer_id, customer_name: @quotation_header.customer_name, effective_period: @quotation_header.effective_period, execution_amount: @quotation_header.execution_amount, fax: @quotation_header.fax, post: @quotation_header.post, quatation_code: @quotation_header.quatation_code, quatation_date: @quotation_header.quatation_date, quote_price: @quotation_header.quote_price, tel: @quotation_header.tel, trading_method: @quotation_header.trading_method }
    end

    assert_redirected_to quotation_header_path(assigns(:quotation_header))
  end

  test "should show quotation_header" do
    get :show, id: @quotation_header
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_header
    assert_response :success
  end

  test "should update quotation_header" do
    patch :update, id: @quotation_header, quotation_header: { address: @quotation_header.address, construction_datum_id: @quotation_header.construction_datum_id, construction_period: @quotation_header.construction_period, construction_place: @quotation_header.construction_place, contsrutction_name: @quotation_header.contsrutction_name, customer_id: @quotation_header.customer_id, customer_name: @quotation_header.customer_name, effective_period: @quotation_header.effective_period, execution_amount: @quotation_header.execution_amount, fax: @quotation_header.fax, post: @quotation_header.post, quatation_code: @quotation_header.quatation_code, quatation_date: @quotation_header.quatation_date, quote_price: @quotation_header.quote_price, tel: @quotation_header.tel, trading_method: @quotation_header.trading_method }
    assert_redirected_to quotation_header_path(assigns(:quotation_header))
  end

  test "should destroy quotation_header" do
    assert_difference('QuotationHeader.count', -1) do
      delete :destroy, id: @quotation_header
    end

    assert_redirected_to quotation_headers_path
  end
end
