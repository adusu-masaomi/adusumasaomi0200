require 'test_helper'

class WorkingUnitsControllerTest < ActionController::TestCase
  setup do
    @working_unit = working_units(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_units)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_unit" do
    assert_difference('WorkingUnit.count') do
      post :create, working_unit: { working_unit_name: @working_unit.working_unit_name }
    end

    assert_redirected_to working_unit_path(assigns(:working_unit))
  end

  test "should show working_unit" do
    get :show, id: @working_unit
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_unit
    assert_response :success
  end

  test "should update working_unit" do
    patch :update, id: @working_unit, working_unit: { working_unit_name: @working_unit.working_unit_name }
    assert_redirected_to working_unit_path(assigns(:working_unit))
  end

  test "should destroy working_unit" do
    assert_difference('WorkingUnit.count', -1) do
      delete :destroy, id: @working_unit
    end

    assert_redirected_to working_units_path
  end
end
