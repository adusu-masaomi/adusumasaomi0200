require 'test_helper'

class WorkingSubcategoriesControllerTest < ActionController::TestCase
  setup do
    @working_subcategory = working_subcategories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_subcategories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_subcategory" do
    assert_difference('WorkingSubcategory.count') do
      post :create, working_subcategory: { name: @working_subcategory.name, working_category_id: @working_subcategory.working_category_id }
    end

    assert_redirected_to working_subcategory_path(assigns(:working_subcategory))
  end

  test "should show working_subcategory" do
    get :show, id: @working_subcategory
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_subcategory
    assert_response :success
  end

  test "should update working_subcategory" do
    patch :update, id: @working_subcategory, working_subcategory: { name: @working_subcategory.name, working_category_id: @working_subcategory.working_category_id }
    assert_redirected_to working_subcategory_path(assigns(:working_subcategory))
  end

  test "should destroy working_subcategory" do
    assert_difference('WorkingSubcategory.count', -1) do
      delete :destroy, id: @working_subcategory
    end

    assert_redirected_to working_subcategories_path
  end
end
