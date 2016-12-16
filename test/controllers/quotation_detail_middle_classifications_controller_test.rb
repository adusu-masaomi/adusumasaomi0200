require 'test_helper'

class QuotationDetailMiddleClassificationsControllerTest < ActionController::TestCase
  setup do
    @quotation_detail_middle_classification = quotation_detail_middle_classifications(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_detail_middle_classifications)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_detail_middle_classification" do
    assert_difference('QuotationDetailMiddleClassification.count') do
      post :create, quotation_detail_middle_classification: { execution_price: @quotation_detail_middle_classification.execution_price, labor_productivity_unit: @quotation_detail_middle_classification.labor_productivity_unit, quantity: @quotation_detail_middle_classification.quantity, quotation_header_id: @quotation_detail_middle_classification.quotation_header_id, quotation_large_classification_detail_id: @quotation_detail_middle_classification.quotation_large_classification_detail_id, quotation_middle_item_id: @quotation_detail_middle_classification.quotation_middle_item_id, quotation_middle_item_name: @quotation_detail_middle_classification.quotation_middle_item_name, quotation_unit_id: @quotation_detail_middle_classification.quotation_unit_id, quote_price: @quotation_detail_middle_classification.quote_price }
    end

    assert_redirected_to quotation_detail_middle_classification_path(assigns(:quotation_detail_middle_classification))
  end

  test "should show quotation_detail_middle_classification" do
    get :show, id: @quotation_detail_middle_classification
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_detail_middle_classification
    assert_response :success
  end

  test "should update quotation_detail_middle_classification" do
    patch :update, id: @quotation_detail_middle_classification, quotation_detail_middle_classification: { execution_price: @quotation_detail_middle_classification.execution_price, labor_productivity_unit: @quotation_detail_middle_classification.labor_productivity_unit, quantity: @quotation_detail_middle_classification.quantity, quotation_header_id: @quotation_detail_middle_classification.quotation_header_id, quotation_large_classification_detail_id: @quotation_detail_middle_classification.quotation_large_classification_detail_id, quotation_middle_item_id: @quotation_detail_middle_classification.quotation_middle_item_id, quotation_middle_item_name: @quotation_detail_middle_classification.quotation_middle_item_name, quotation_unit_id: @quotation_detail_middle_classification.quotation_unit_id, quote_price: @quotation_detail_middle_classification.quote_price }
    assert_redirected_to quotation_detail_middle_classification_path(assigns(:quotation_detail_middle_classification))
  end

  test "should destroy quotation_detail_middle_classification" do
    assert_difference('QuotationDetailMiddleClassification.count', -1) do
      delete :destroy, id: @quotation_detail_middle_classification
    end

    assert_redirected_to quotation_detail_middle_classifications_path
  end
end
