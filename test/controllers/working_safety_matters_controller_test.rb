require 'test_helper'

class WorkingSafetyMattersControllerTest < ActionController::TestCase
  setup do
    @working_safety_matter = working_safety_matters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_safety_matters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_safety_matter" do
    assert_difference('WorkingSafetyMatter.count') do
      post :create, working_safety_matter: { name: @working_safety_matter.name }
    end

    assert_redirected_to working_safety_matter_path(assigns(:working_safety_matter))
  end

  test "should show working_safety_matter" do
    get :show, id: @working_safety_matter
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_safety_matter
    assert_response :success
  end

  test "should update working_safety_matter" do
    patch :update, id: @working_safety_matter, working_safety_matter: { name: @working_safety_matter.name }
    assert_redirected_to working_safety_matter_path(assigns(:working_safety_matter))
  end

  test "should destroy working_safety_matter" do
    assert_difference('WorkingSafetyMatter.count', -1) do
      delete :destroy, id: @working_safety_matter
    end

    assert_redirected_to working_safety_matters_path
  end
end
