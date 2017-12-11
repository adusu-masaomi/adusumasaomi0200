require 'test_helper'

class InvoiceDetailMiddleClassificationsControllerTest < ActionController::TestCase
  setup do
    @invoice_detail_middle_classification = invoice_detail_middle_classifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:invoice_detail_middle_classifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create invoice_detail_middle_classification" do
    assert_difference('InvoiceDetailMiddleClassification.count') do
      post :create, invoice_detail_middle_classification: { accessory_cost: @invoice_detail_middle_classification.accessory_cost, execution_price: @invoice_detail_middle_classification.execution_price, execution_quantity: @invoice_detail_middle_classification.execution_quantity, execution_unit_price: @invoice_detail_middle_classification.execution_unit_price, invoice_detail_large_classification_id: @invoice_detail_middle_classification.invoice_detail_large_classification_id, invoice_header_id: @invoice_detail_middle_classification.invoice_header_id, invoice_item_division_id: @invoice_detail_middle_classification.invoice_item_division_id, invoice_price: @invoice_detail_middle_classification.invoice_price, labor_cost_total: @invoice_detail_middle_classification.labor_cost_total, labor_productivity_unit: @invoice_detail_middle_classification.labor_productivity_unit, labor_productivity_unit_total: @invoice_detail_middle_classification.labor_productivity_unit_total, labor_unit_price: @invoice_detail_middle_classification.labor_unit_price, line_number: @invoice_detail_middle_classification.line_number, material_cost_total: @invoice_detail_middle_classification.material_cost_total, material_id: @invoice_detail_middle_classification.material_id, material_id: @invoice_detail_middle_classification.material_id, material_quantity: @invoice_detail_middle_classification.material_quantity, material_unit_price: @invoice_detail_middle_classification.material_unit_price, other_cost: @invoice_detail_middle_classification.other_cost, quantity: @invoice_detail_middle_classification.quantity, working_material_name: @invoice_detail_middle_classification.working_material_name, working_middle_item_id: @invoice_detail_middle_classification.working_middle_item_id, working_middle_item_name: @invoice_detail_middle_classification.working_middle_item_name, working_middle_item_short_name: @invoice_detail_middle_classification.working_middle_item_short_name, working_middle_specification: @invoice_detail_middle_classification.working_middle_specification, working_unit_id: @invoice_detail_middle_classification.working_unit_id, working_unit_name: @invoice_detail_middle_classification.working_unit_name, working_unit_price: @invoice_detail_middle_classification.working_unit_price }
    end

    assert_redirected_to invoice_detail_middle_classification_path(assigns(:invoice_detail_middle_classification))
  end

  test "should show invoice_detail_middle_classification" do
    get :show, id: @invoice_detail_middle_classification
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @invoice_detail_middle_classification
    assert_response :success
  end

  test "should update invoice_detail_middle_classification" do
    patch :update, id: @invoice_detail_middle_classification, invoice_detail_middle_classification: { accessory_cost: @invoice_detail_middle_classification.accessory_cost, execution_price: @invoice_detail_middle_classification.execution_price, execution_quantity: @invoice_detail_middle_classification.execution_quantity, execution_unit_price: @invoice_detail_middle_classification.execution_unit_price, invoice_detail_large_classification_id: @invoice_detail_middle_classification.invoice_detail_large_classification_id, invoice_header_id: @invoice_detail_middle_classification.invoice_header_id, invoice_item_division_id: @invoice_detail_middle_classification.invoice_item_division_id, invoice_price: @invoice_detail_middle_classification.invoice_price, labor_cost_total: @invoice_detail_middle_classification.labor_cost_total, labor_productivity_unit: @invoice_detail_middle_classification.labor_productivity_unit, labor_productivity_unit_total: @invoice_detail_middle_classification.labor_productivity_unit_total, labor_unit_price: @invoice_detail_middle_classification.labor_unit_price, line_number: @invoice_detail_middle_classification.line_number, material_cost_total: @invoice_detail_middle_classification.material_cost_total, material_id: @invoice_detail_middle_classification.material_id, material_id: @invoice_detail_middle_classification.material_id, material_quantity: @invoice_detail_middle_classification.material_quantity, material_unit_price: @invoice_detail_middle_classification.material_unit_price, other_cost: @invoice_detail_middle_classification.other_cost, quantity: @invoice_detail_middle_classification.quantity, working_material_name: @invoice_detail_middle_classification.working_material_name, working_middle_item_id: @invoice_detail_middle_classification.working_middle_item_id, working_middle_item_name: @invoice_detail_middle_classification.working_middle_item_name, working_middle_item_short_name: @invoice_detail_middle_classification.working_middle_item_short_name, working_middle_specification: @invoice_detail_middle_classification.working_middle_specification, working_unit_id: @invoice_detail_middle_classification.working_unit_id, working_unit_name: @invoice_detail_middle_classification.working_unit_name, working_unit_price: @invoice_detail_middle_classification.working_unit_price }
    assert_redirected_to invoice_detail_middle_classification_path(assigns(:invoice_detail_middle_classification))
  end

  test "should destroy invoice_detail_middle_classification" do
    assert_difference('InvoiceDetailMiddleClassification.count', -1) do
      delete :destroy, id: @invoice_detail_middle_classification
    end

    assert_redirected_to invoice_detail_middle_classifications_path
  end
end
