require 'test_helper'

class ConstructionDataControllerTest < ActionController::TestCase
  setup do
    @construction_datum = construction_data(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:construction_data)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create construction_datum" do
    assert_difference('ConstructionDatum.count') do
      post :create, construction_datum: { construction_code: @construction_datum.construction_code, construction_end_date: @construction_datum.construction_end_date, construction_name: @construction_datum.construction_name, construction_start_date: @construction_datum.construction_start_date, customer_id: @construction_datum.customer_id, reception_date: @construction_datum.reception_date }
    end

    assert_redirected_to construction_datum_path(assigns(:construction_datum))
  end

  test "should show construction_datum" do
    get :show, id: @construction_datum
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @construction_datum
    assert_response :success
  end

  test "should update construction_datum" do
    patch :update, id: @construction_datum, construction_datum: { construction_code: @construction_datum.construction_code, construction_end_date: @construction_datum.construction_end_date, construction_name: @construction_datum.construction_name, construction_start_date: @construction_datum.construction_start_date, customer_id: @construction_datum.customer_id, reception_date: @construction_datum.reception_date }
    assert_redirected_to construction_datum_path(assigns(:construction_datum))
  end

  test "should destroy construction_datum" do
    assert_difference('ConstructionDatum.count', -1) do
      delete :destroy, id: @construction_datum
    end

    assert_redirected_to construction_data_path
  end
end
