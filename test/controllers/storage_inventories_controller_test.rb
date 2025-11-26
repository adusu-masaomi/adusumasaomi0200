require 'test_helper'

class StorageInventoriesControllerTest < ActionController::TestCase
  setup do
    @storage_inventory = storage_inventories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:storage_inventories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create storage_inventory" do
    assert_difference('StorageInventory.count') do
      post :create, storage_inventory: { material_master_id: @storage_inventory.material_master_id, quantity: @storage_inventory.quantity, unit_price: @storage_inventory.unit_price }
    end

    assert_redirected_to storage_inventory_path(assigns(:storage_inventory))
  end

  test "should show storage_inventory" do
    get :show, id: @storage_inventory
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @storage_inventory
    assert_response :success
  end

  test "should update storage_inventory" do
    patch :update, id: @storage_inventory, storage_inventory: { material_master_id: @storage_inventory.material_master_id, quantity: @storage_inventory.quantity, unit_price: @storage_inventory.unit_price }
    assert_redirected_to storage_inventory_path(assigns(:storage_inventory))
  end

  test "should destroy storage_inventory" do
    assert_difference('StorageInventory.count', -1) do
      delete :destroy, id: @storage_inventory
    end

    assert_redirected_to storage_inventories_path
  end
end
