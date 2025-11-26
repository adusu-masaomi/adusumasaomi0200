require 'test_helper'

class StorageInventoryHistoriesControllerTest < ActionController::TestCase
  setup do
    @storage_inventory_history = storage_inventory_histories(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:storage_inventory_histories)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create storage_inventory_history" do
    assert_difference('StorageInventoryHistory.count') do
      post :create, storage_inventory_history: { amount: @storage_inventory_history.amount, construction_datum_id: @storage_inventory_history.construction_datum_id, invenrtory_division_id: @storage_inventory_history.invenrtory_division_id, material_master_id: @storage_inventory_history.material_master_id, occurred_date: @storage_inventory_history.occurred_date, purchase_order_datum_id: @storage_inventory_history.purchase_order_datum_id, quantity: @storage_inventory_history.quantity, slip_code: @storage_inventory_history.slip_code, supplier_master_id: @storage_inventory_history.supplier_master_id, unit_price: @storage_inventory_history.unit_price }
    end

    assert_redirected_to storage_inventory_history_path(assigns(:storage_inventory_history))
  end

  test "should show storage_inventory_history" do
    get :show, id: @storage_inventory_history
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @storage_inventory_history
    assert_response :success
  end

  test "should update storage_inventory_history" do
    patch :update, id: @storage_inventory_history, storage_inventory_history: { amount: @storage_inventory_history.amount, construction_datum_id: @storage_inventory_history.construction_datum_id, invenrtory_division_id: @storage_inventory_history.invenrtory_division_id, material_master_id: @storage_inventory_history.material_master_id, occurred_date: @storage_inventory_history.occurred_date, purchase_order_datum_id: @storage_inventory_history.purchase_order_datum_id, quantity: @storage_inventory_history.quantity, slip_code: @storage_inventory_history.slip_code, supplier_master_id: @storage_inventory_history.supplier_master_id, unit_price: @storage_inventory_history.unit_price }
    assert_redirected_to storage_inventory_history_path(assigns(:storage_inventory_history))
  end

  test "should destroy storage_inventory_history" do
    assert_difference('StorageInventoryHistory.count', -1) do
      delete :destroy, id: @storage_inventory_history
    end

    assert_redirected_to storage_inventory_histories_path
  end
end
