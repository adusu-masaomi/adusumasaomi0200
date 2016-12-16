require 'test_helper'

class UnitMastersControllerTest < ActionController::TestCase
  setup do
    @unit_master = unit_masters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:unit_masters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create unit_master" do
    assert_difference('UnitMaster.count') do
      post :create, unit_master: { unit_name: @unit_master.unit_name }
    end

    assert_redirected_to unit_master_path(assigns(:unit_master))
  end

  test "should show unit_master" do
    get :show, id: @unit_master
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @unit_master
    assert_response :success
  end

  test "should update unit_master" do
    patch :update, id: @unit_master, unit_master: { unit_name: @unit_master.unit_name }
    assert_redirected_to unit_master_path(assigns(:unit_master))
  end

  test "should destroy unit_master" do
    assert_difference('UnitMaster.count', -1) do
      delete :destroy, id: @unit_master
    end

    assert_redirected_to unit_masters_path
  end
end
