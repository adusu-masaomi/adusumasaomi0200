require 'test_helper'

class StocktakesControllerTest < ActionController::TestCase
  setup do
    @stocktake = stocktakes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:stocktakes)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create stocktake" do
    assert_difference('Stocktake.count') do
      post :create, stocktake: { book_quantity: @stocktake.book_quantity, material_master_id: @stocktake.material_master_id, physical_amount: @stocktake.physical_amount, physical_quantity: @stocktake.physical_quantity, stocktake_date: @stocktake.stocktake_date, unit_price: @stocktake.unit_price }
    end

    assert_redirected_to stocktake_path(assigns(:stocktake))
  end

  test "should show stocktake" do
    get :show, id: @stocktake
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @stocktake
    assert_response :success
  end

  test "should update stocktake" do
    patch :update, id: @stocktake, stocktake: { book_quantity: @stocktake.book_quantity, material_master_id: @stocktake.material_master_id, physical_amount: @stocktake.physical_amount, physical_quantity: @stocktake.physical_quantity, stocktake_date: @stocktake.stocktake_date, unit_price: @stocktake.unit_price }
    assert_redirected_to stocktake_path(assigns(:stocktake))
  end

  test "should destroy stocktake" do
    assert_difference('Stocktake.count', -1) do
      delete :destroy, id: @stocktake
    end

    assert_redirected_to stocktakes_path
  end
end
