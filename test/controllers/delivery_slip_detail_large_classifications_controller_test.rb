require 'test_helper'

class DeliverySlipDetailLargeClassificationsControllerTest < ActionController::TestCase
  setup do
    @delivery_slip_detail_large_classification = delivery_slip_detail_large_classifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:delivery_slip_detail_large_classifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create delivery_slip_detail_large_classification" do
    assert_difference('DeliverySlipDetailLargeClassification.count') do
      post :create, delivery_slip_detail_large_classification: { delivery_slip_header_id: @delivery_slip_detail_large_classification.delivery_slip_header_id, delivery_slip_items_division_id: @delivery_slip_detail_large_classification.delivery_slip_items_division_id, delivery_slip_large_item_id: @delivery_slip_detail_large_classification.delivery_slip_large_item_id, delivery_slip_large_item_name: @delivery_slip_detail_large_classification.delivery_slip_large_item_name, delivery_slip_large_specification: @delivery_slip_detail_large_classification.delivery_slip_large_specification, delivery_slip_price: @delivery_slip_detail_large_classification.delivery_slip_price, delivery_slip_unit_price: @delivery_slip_detail_large_classification.delivery_slip_unit_price, exectuion_unit_price: @delivery_slip_detail_large_classification.exectuion_unit_price, execution_price: @delivery_slip_detail_large_classification.execution_price, execution_quantity: @delivery_slip_detail_large_classification.execution_quantity, labor_productivity_unit: @delivery_slip_detail_large_classification.labor_productivity_unit, labor_productivity_unit_total: @delivery_slip_detail_large_classification.labor_productivity_unit_total, last_line_number: @delivery_slip_detail_large_classification.last_line_number, line_number: @delivery_slip_detail_large_classification.line_number, quantity: @delivery_slip_detail_large_classification.quantity, quotation_unit_id: @delivery_slip_detail_large_classification.quotation_unit_id, quotation_unit_name: @delivery_slip_detail_large_classification.quotation_unit_name }
    end

    assert_redirected_to delivery_slip_detail_large_classification_path(assigns(:delivery_slip_detail_large_classification))
  end

  test "should show delivery_slip_detail_large_classification" do
    get :show, id: @delivery_slip_detail_large_classification
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @delivery_slip_detail_large_classification
    assert_response :success
  end

  test "should update delivery_slip_detail_large_classification" do
    patch :update, id: @delivery_slip_detail_large_classification, delivery_slip_detail_large_classification: { delivery_slip_header_id: @delivery_slip_detail_large_classification.delivery_slip_header_id, delivery_slip_items_division_id: @delivery_slip_detail_large_classification.delivery_slip_items_division_id, delivery_slip_large_item_id: @delivery_slip_detail_large_classification.delivery_slip_large_item_id, delivery_slip_large_item_name: @delivery_slip_detail_large_classification.delivery_slip_large_item_name, delivery_slip_large_specification: @delivery_slip_detail_large_classification.delivery_slip_large_specification, delivery_slip_price: @delivery_slip_detail_large_classification.delivery_slip_price, delivery_slip_unit_price: @delivery_slip_detail_large_classification.delivery_slip_unit_price, exectuion_unit_price: @delivery_slip_detail_large_classification.exectuion_unit_price, execution_price: @delivery_slip_detail_large_classification.execution_price, execution_quantity: @delivery_slip_detail_large_classification.execution_quantity, labor_productivity_unit: @delivery_slip_detail_large_classification.labor_productivity_unit, labor_productivity_unit_total: @delivery_slip_detail_large_classification.labor_productivity_unit_total, last_line_number: @delivery_slip_detail_large_classification.last_line_number, line_number: @delivery_slip_detail_large_classification.line_number, quantity: @delivery_slip_detail_large_classification.quantity, quotation_unit_id: @delivery_slip_detail_large_classification.quotation_unit_id, quotation_unit_name: @delivery_slip_detail_large_classification.quotation_unit_name }
    assert_redirected_to delivery_slip_detail_large_classification_path(assigns(:delivery_slip_detail_large_classification))
  end

  test "should destroy delivery_slip_detail_large_classification" do
    assert_difference('DeliverySlipDetailLargeClassification.count', -1) do
      delete :destroy, id: @delivery_slip_detail_large_classification
    end

    assert_redirected_to delivery_slip_detail_large_classifications_path
  end
end
