require 'test_helper'

class InventoryCategoriesControllerTest < ActionController::TestCase
  setup do
    @inventory_category = inventory_categories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inventory_categories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inventory_category" do
    assert_difference('InventoryCategory.count') do
      post :create, inventory_category: { name: @inventory_category.name, seq: @inventory_category.seq }
    end

    assert_redirected_to inventory_category_path(assigns(:inventory_category))
  end

  test "should show inventory_category" do
    get :show, id: @inventory_category
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @inventory_category
    assert_response :success
  end

  test "should update inventory_category" do
    patch :update, id: @inventory_category, inventory_category: { name: @inventory_category.name, seq: @inventory_category.seq }
    assert_redirected_to inventory_category_path(assigns(:inventory_category))
  end

  test "should destroy inventory_category" do
    assert_difference('InventoryCategory.count', -1) do
      delete :destroy, id: @inventory_category
    end

    assert_redirected_to inventory_categories_path
  end
end
