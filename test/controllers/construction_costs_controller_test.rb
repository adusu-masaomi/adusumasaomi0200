require 'test_helper'

class ConstructionCostsControllerTest < ActionController::TestCase
  setup do
    @construction_cost = construction_costs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:construction_costs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create construction_cost" do
    assert_difference('ConstructionCost.count') do
      post :create, construction_cost: { constructing_amount: @construction_cost.constructing_amount, construction_id: @construction_cost.construction_id, labor_cost: @construction_cost.labor_cost, misellaneous_expense: @construction_cost.misellaneous_expense, supplies_expense: @construction_cost.supplies_expense }
    end

    assert_redirected_to construction_cost_path(assigns(:construction_cost))
  end

  test "should show construction_cost" do
    get :show, id: @construction_cost
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @construction_cost
    assert_response :success
  end

  test "should update construction_cost" do
    patch :update, id: @construction_cost, construction_cost: { constructing_amount: @construction_cost.constructing_amount, construction_id: @construction_cost.construction_id, labor_cost: @construction_cost.labor_cost, misellaneous_expense: @construction_cost.misellaneous_expense, supplies_expense: @construction_cost.supplies_expense }
    assert_redirected_to construction_cost_path(assigns(:construction_cost))
  end

  test "should destroy construction_cost" do
    assert_difference('ConstructionCost.count', -1) do
      delete :destroy, id: @construction_cost
    end

    assert_redirected_to construction_costs_path
  end
end
