require 'test_helper'

class DeliverySlipHeadersControllerTest < ActionController::TestCase
  setup do
    @delivery_slip_header = delivery_slip_headers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:delivery_slip_headers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delivery_slip_header" do
    assert_difference('DeliverySlipHeader.count') do
      post :create, delivery_slip_header: { address: @delivery_slip_header.address, construction_datum_id: @delivery_slip_header.construction_datum_id, construction_name: @delivery_slip_header.construction_name, construction_place: @delivery_slip_header.construction_place, customer_id: @delivery_slip_header.customer_id, customer_name: @delivery_slip_header.customer_name, delivery_amount: @delivery_slip_header.delivery_amount, delivery_slip_code: @delivery_slip_header.delivery_slip_code, delivery_slip_date: @delivery_slip_header.delivery_slip_date, execution_amount: @delivery_slip_header.execution_amount, fax: @delivery_slip_header.fax, honorific_id: @delivery_slip_header.honorific_id, invoice_code: @delivery_slip_header.invoice_code, last_line_number: @delivery_slip_header.last_line_number, post: @delivery_slip_header.post, quotation_code: @delivery_slip_header.quotation_code, responsible1: @delivery_slip_header.responsible1, responsible2: @delivery_slip_header.responsible2, tel: @delivery_slip_header.tel }
    end

    assert_redirected_to delivery_slip_header_path(assigns(:delivery_slip_header))
  end

  test "should show delivery_slip_header" do
    get :show, id: @delivery_slip_header
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @delivery_slip_header
    assert_response :success
  end

  test "should update delivery_slip_header" do
    patch :update, id: @delivery_slip_header, delivery_slip_header: { address: @delivery_slip_header.address, construction_datum_id: @delivery_slip_header.construction_datum_id, construction_name: @delivery_slip_header.construction_name, construction_place: @delivery_slip_header.construction_place, customer_id: @delivery_slip_header.customer_id, customer_name: @delivery_slip_header.customer_name, delivery_amount: @delivery_slip_header.delivery_amount, delivery_slip_code: @delivery_slip_header.delivery_slip_code, delivery_slip_date: @delivery_slip_header.delivery_slip_date, execution_amount: @delivery_slip_header.execution_amount, fax: @delivery_slip_header.fax, honorific_id: @delivery_slip_header.honorific_id, invoice_code: @delivery_slip_header.invoice_code, last_line_number: @delivery_slip_header.last_line_number, post: @delivery_slip_header.post, quotation_code: @delivery_slip_header.quotation_code, responsible1: @delivery_slip_header.responsible1, responsible2: @delivery_slip_header.responsible2, tel: @delivery_slip_header.tel }
    assert_redirected_to delivery_slip_header_path(assigns(:delivery_slip_header))
  end

  test "should destroy delivery_slip_header" do
    assert_difference('DeliverySlipHeader.count', -1) do
      delete :destroy, id: @delivery_slip_header
    end

    assert_redirected_to delivery_slip_headers_path
  end
end
