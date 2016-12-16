require 'test_helper'

class QuotationUnitsControllerTest < ActionController::TestCase
  setup do
    @quotation_unit = quotation_units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_unit" do
    assert_difference('QuotationUnit.count') do
      post :create, quotation_unit: { quotation_unit_name: @quotation_unit.quotation_unit_name }
    end

    assert_redirected_to quotation_unit_path(assigns(:quotation_unit))
  end

  test "should show quotation_unit" do
    get :show, id: @quotation_unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_unit
    assert_response :success
  end

  test "should update quotation_unit" do
    patch :update, id: @quotation_unit, quotation_unit: { quotation_unit_name: @quotation_unit.quotation_unit_name }
    assert_redirected_to quotation_unit_path(assigns(:quotation_unit))
  end

  test "should destroy quotation_unit" do
    assert_difference('QuotationUnit.count', -1) do
      delete :destroy, id: @quotation_unit
    end

    assert_redirected_to quotation_units_path
  end
end
