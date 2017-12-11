require 'test_helper'

class WorkingCategoriesControllerTest < ActionController::TestCase
  setup do
    @working_category = working_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:working_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create working_category" do
    assert_difference('WorkingCategory.count') do
      post :create, working_category: { category_name: @working_category.category_name }
    end

    assert_redirected_to working_category_path(assigns(:working_category))
  end

  test "should show working_category" do
    get :show, id: @working_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @working_category
    assert_response :success
  end

  test "should update working_category" do
    patch :update, id: @working_category, working_category: { category_name: @working_category.category_name }
    assert_redirected_to working_category_path(assigns(:working_category))
  end

  test "should destroy working_category" do
    assert_difference('WorkingCategory.count', -1) do
      delete :destroy, id: @working_category
    end

    assert_redirected_to working_categories_path
  end
end
