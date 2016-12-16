require 'test_helper'

class QuotationItemsDivisionsControllerTest < ActionController::TestCase
  setup do
    @quotation_items_division = quotation_items_divisions(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_items_divisions)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_items_division" do
    assert_difference('QuotationItemsDivision.count') do
      post :create, quotation_items_division: { quotation_items_division_name: @quotation_items_division.quotation_items_division_name }
    end

    assert_redirected_to quotation_items_division_path(assigns(:quotation_items_division))
  end

  test "should show quotation_items_division" do
    get :show, id: @quotation_items_division
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_items_division
    assert_response :success
  end

  test "should update quotation_items_division" do
    patch :update, id: @quotation_items_division, quotation_items_division: { quotation_items_division_name: @quotation_items_division.quotation_items_division_name }
    assert_redirected_to quotation_items_division_path(assigns(:quotation_items_division))
  end

  test "should destroy quotation_items_division" do
    assert_difference('QuotationItemsDivision.count', -1) do
      delete :destroy, id: @quotation_items_division
    end

    assert_redirected_to quotation_items_divisions_path
  end
end
