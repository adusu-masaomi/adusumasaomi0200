require 'test_helper'

class InvoiceHeadersControllerTest < ActionController::TestCase
  setup do
    @invoice_header = invoice_headers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_headers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_header" do
    assert_difference('InvoiceHeader.count') do
      post :create, invoice_header: { address: @invoice_header.address, billing_amount: @invoice_header.billing_amount, construction_datum_id: @invoice_header.construction_datum_id, construction_name: @invoice_header.construction_name, construction_place: @invoice_header.construction_place, customer_id: @invoice_header.customer_id, customer_name: @invoice_header.customer_name, delivery_slip_code: @invoice_header.delivery_slip_code, execution_amount: @invoice_header.execution_amount, fax: @invoice_header.fax, honorific_id: @invoice_header.honorific_id, invoice_code: @invoice_header.invoice_code, invoice_date: @invoice_header.invoice_date, invoice_period_end_date: @invoice_header.invoice_period_end_date, invoice_period_start_date: @invoice_header.invoice_period_start_date, last_line_number: @invoice_header.last_line_number, payment_period: @invoice_header.payment_period, post: @invoice_header.post, quotation_code: @invoice_header.quotation_code, responsible1: @invoice_header.responsible1, responsible2: @invoice_header.responsible2, tel: @invoice_header.tel }
    end

    assert_redirected_to invoice_header_path(assigns(:invoice_header))
  end

  test "should show invoice_header" do
    get :show, id: @invoice_header
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice_header
    assert_response :success
  end

  test "should update invoice_header" do
    patch :update, id: @invoice_header, invoice_header: { address: @invoice_header.address, billing_amount: @invoice_header.billing_amount, construction_datum_id: @invoice_header.construction_datum_id, construction_name: @invoice_header.construction_name, construction_place: @invoice_header.construction_place, customer_id: @invoice_header.customer_id, customer_name: @invoice_header.customer_name, delivery_slip_code: @invoice_header.delivery_slip_code, execution_amount: @invoice_header.execution_amount, fax: @invoice_header.fax, honorific_id: @invoice_header.honorific_id, invoice_code: @invoice_header.invoice_code, invoice_date: @invoice_header.invoice_date, invoice_period_end_date: @invoice_header.invoice_period_end_date, invoice_period_start_date: @invoice_header.invoice_period_start_date, last_line_number: @invoice_header.last_line_number, payment_period: @invoice_header.payment_period, post: @invoice_header.post, quotation_code: @invoice_header.quotation_code, responsible1: @invoice_header.responsible1, responsible2: @invoice_header.responsible2, tel: @invoice_header.tel }
    assert_redirected_to invoice_header_path(assigns(:invoice_header))
  end

  test "should destroy invoice_header" do
    assert_difference('InvoiceHeader.count', -1) do
      delete :destroy, id: @invoice_header
    end

    assert_redirected_to invoice_headers_path
  end
end
