require 'test_helper'

class MakerMastersControllerTest < ActionController::TestCase
  setup do
    @maker_master = maker_masters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:maker_masters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create maker_master" do
    assert_difference('MakerMaster.count') do
      post :create, maker_master: { maker_name: @maker_master.maker_name }
    end

    assert_redirected_to maker_master_path(assigns(:maker_master))
  end

  test "should show maker_master" do
    get :show, id: @maker_master
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @maker_master
    assert_response :success
  end

  test "should update maker_master" do
    patch :update, id: @maker_master, maker_master: { maker_name: @maker_master.maker_name }
    assert_redirected_to maker_master_path(assigns(:maker_master))
  end

  test "should destroy maker_master" do
    assert_difference('MakerMaster.count', -1) do
      delete :destroy, id: @maker_master
    end

    assert_redirected_to maker_masters_path
  end
end
