require 'test_helper'

class InvoiceDetailLargeClassificationsControllerTest < ActionController::TestCase
  setup do
    @invoice_detail_large_classification = invoice_detail_large_classifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_detail_large_classifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_detail_large_classification" do
    assert_difference('InvoiceDetailLargeClassification.count') do
      post :create, invoice_detail_large_classification: { exectuion_unit_price: @invoice_detail_large_classification.exectuion_unit_price, execution_price: @invoice_detail_large_classification.execution_price, execution_quantity: @invoice_detail_large_classification.execution_quantity, invoice_header_id: @invoice_detail_large_classification.invoice_header_id, invoice_items_division_id: @invoice_detail_large_classification.invoice_items_division_id, invoice_large_item_id: @invoice_detail_large_classification.invoice_large_item_id, invoice_large_item_name: @invoice_detail_large_classification.invoice_large_item_name, invoice_large_specification: @invoice_detail_large_classification.invoice_large_specification, invoice_price: @invoice_detail_large_classification.invoice_price, invoice_unit_price: @invoice_detail_large_classification.invoice_unit_price, labor_productivity_unit: @invoice_detail_large_classification.labor_productivity_unit, labor_productivity_unit_total: @invoice_detail_large_classification.labor_productivity_unit_total, last_line_number: @invoice_detail_large_classification.last_line_number, line_number: @invoice_detail_large_classification.line_number, quantity: @invoice_detail_large_classification.quantity, quotation_unit_id: @invoice_detail_large_classification.quotation_unit_id, quotation_unit_name: @invoice_detail_large_classification.quotation_unit_name }
    end

    assert_redirected_to invoice_detail_large_classification_path(assigns(:invoice_detail_large_classification))
  end

  test "should show invoice_detail_large_classification" do
    get :show, id: @invoice_detail_large_classification
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice_detail_large_classification
    assert_response :success
  end

  test "should update invoice_detail_large_classification" do
    patch :update, id: @invoice_detail_large_classification, invoice_detail_large_classification: { exectuion_unit_price: @invoice_detail_large_classification.exectuion_unit_price, execution_price: @invoice_detail_large_classification.execution_price, execution_quantity: @invoice_detail_large_classification.execution_quantity, invoice_header_id: @invoice_detail_large_classification.invoice_header_id, invoice_items_division_id: @invoice_detail_large_classification.invoice_items_division_id, invoice_large_item_id: @invoice_detail_large_classification.invoice_large_item_id, invoice_large_item_name: @invoice_detail_large_classification.invoice_large_item_name, invoice_large_specification: @invoice_detail_large_classification.invoice_large_specification, invoice_price: @invoice_detail_large_classification.invoice_price, invoice_unit_price: @invoice_detail_large_classification.invoice_unit_price, labor_productivity_unit: @invoice_detail_large_classification.labor_productivity_unit, labor_productivity_unit_total: @invoice_detail_large_classification.labor_productivity_unit_total, last_line_number: @invoice_detail_large_classification.last_line_number, line_number: @invoice_detail_large_classification.line_number, quantity: @invoice_detail_large_classification.quantity, quotation_unit_id: @invoice_detail_large_classification.quotation_unit_id, quotation_unit_name: @invoice_detail_large_classification.quotation_unit_name }
    assert_redirected_to invoice_detail_large_classification_path(assigns(:invoice_detail_large_classification))
  end

  test "should destroy invoice_detail_large_classification" do
    assert_difference('InvoiceDetailLargeClassification.count', -1) do
      delete :destroy, id: @invoice_detail_large_classification
    end

    assert_redirected_to invoice_detail_large_classifications_path
  end
end
