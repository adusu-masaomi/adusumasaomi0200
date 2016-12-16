require 'test_helper'

class MaterialMastersControllerTest < ActionController::TestCase
  setup do
    @material_master = material_masters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:material_masters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create material_master" do
    assert_difference('MaterialMaster.count') do
      post :create, material_master: { material_code: @material_master.material_code, material_name: @material_master.material_name }
    end

    assert_redirected_to material_master_path(assigns(:material_master))
  end

  test "should show material_master" do
    get :show, id: @material_master
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @material_master
    assert_response :success
  end

  test "should update material_master" do
    patch :update, id: @material_master, material_master: { material_code: @material_master.material_code, material_name: @material_master.material_name }
    assert_redirected_to material_master_path(assigns(:material_master))
  end

  test "should destroy material_master" do
    assert_difference('MaterialMaster.count', -1) do
      delete :destroy, id: @material_master
    end

    assert_redirected_to material_masters_path
  end
end
