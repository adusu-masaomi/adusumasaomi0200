require 'test_helper'

class InventoriesControllerTest < ActionController::TestCase
  setup do
    @inventory = inventories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:inventories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create inventory" do
    assert_difference('Inventory.count') do
      post :create, inventory: { inventory_amount: @inventory.inventory_amount, inventory_quantity: @inventory.inventory_quantity, location_id: @inventory.location_id, material_master_id: @inventory.material_master_id, unit_price_1: @inventory.unit_price_1, unit_price_2: @inventory.unit_price_2, unit_price_3: @inventory.unit_price_3, warehouse_id: @inventory.warehouse_id }
    end

    assert_redirected_to inventory_path(assigns(:inventory))
  end

  test "should show inventory" do
    get :show, id: @inventory
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @inventory
    assert_response :success
  end

  test "should update inventory" do
    patch :update, id: @inventory, inventory: { inventory_amount: @inventory.inventory_amount, inventory_quantity: @inventory.inventory_quantity, location_id: @inventory.location_id, material_master_id: @inventory.material_master_id, unit_price_1: @inventory.unit_price_1, unit_price_2: @inventory.unit_price_2, unit_price_3: @inventory.unit_price_3, warehouse_id: @inventory.warehouse_id }
    assert_redirected_to inventory_path(assigns(:inventory))
  end

  test "should destroy inventory" do
    assert_difference('Inventory.count', -1) do
      delete :destroy, id: @inventory
    end

    assert_redirected_to inventories_path
  end
end
