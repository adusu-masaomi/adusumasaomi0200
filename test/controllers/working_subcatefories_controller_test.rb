require 'test_helper'

class WorkingSubcateforiesControllerTest < ActionController::TestCase
  setup do
    @working_subcatefory = working_subcatefories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_subcatefories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_subcatefory" do
    assert_difference('WorkingSubcatefory.count') do
      post :create, working_subcatefory: { name: @working_subcatefory.name, working_category_id: @working_subcatefory.working_category_id }
    end

    assert_redirected_to working_subcatefory_path(assigns(:working_subcatefory))
  end

  test "should show working_subcatefory" do
    get :show, id: @working_subcatefory
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_subcatefory
    assert_response :success
  end

  test "should update working_subcatefory" do
    patch :update, id: @working_subcatefory, working_subcatefory: { name: @working_subcatefory.name, working_category_id: @working_subcatefory.working_category_id }
    assert_redirected_to working_subcatefory_path(assigns(:working_subcatefory))
  end

  test "should destroy working_subcatefory" do
    assert_difference('WorkingSubcatefory.count', -1) do
      delete :destroy, id: @working_subcatefory
    end

    assert_redirected_to working_subcatefories_path
  end
end
