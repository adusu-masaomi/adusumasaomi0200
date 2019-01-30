require 'test_helper'

class OutsourcingCostsControllerTest < ActionController::TestCase
  setup do
    @outsourcing_cost = outsourcing_costs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:outsourcing_costs)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create outsourcing_cost" do
    assert_difference('OutsourcingCost.count') do
      post :create, outsourcing_cost: { billing_amount: @outsourcing_cost.billing_amount, closing_date: @outsourcing_cost.closing_date, construction_datum_id: @outsourcing_cost.construction_datum_id, execution_amount: @outsourcing_cost.execution_amount, labor_cost: @outsourcing_cost.labor_cost, misellaneous_expense: @outsourcing_cost.misellaneous_expense, payment_amount: @outsourcing_cost.payment_amount, payment_date: @outsourcing_cost.payment_date, payment_due_date: @outsourcing_cost.payment_due_date, purchase_amount: @outsourcing_cost.purchase_amount, purchase_order_amount: @outsourcing_cost.purchase_order_amount, staff_id: @outsourcing_cost.staff_id, supplies_expense: @outsourcing_cost.supplies_expense, unpaid_amount: @outsourcing_cost.unpaid_amount }
    end

    assert_redirected_to outsourcing_cost_path(assigns(:outsourcing_cost))
  end

  test "should show outsourcing_cost" do
    get :show, id: @outsourcing_cost
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @outsourcing_cost
    assert_response :success
  end

  test "should update outsourcing_cost" do
    patch :update, id: @outsourcing_cost, outsourcing_cost: { billing_amount: @outsourcing_cost.billing_amount, closing_date: @outsourcing_cost.closing_date, construction_datum_id: @outsourcing_cost.construction_datum_id, execution_amount: @outsourcing_cost.execution_amount, labor_cost: @outsourcing_cost.labor_cost, misellaneous_expense: @outsourcing_cost.misellaneous_expense, payment_amount: @outsourcing_cost.payment_amount, payment_date: @outsourcing_cost.payment_date, payment_due_date: @outsourcing_cost.payment_due_date, purchase_amount: @outsourcing_cost.purchase_amount, purchase_order_amount: @outsourcing_cost.purchase_order_amount, staff_id: @outsourcing_cost.staff_id, supplies_expense: @outsourcing_cost.supplies_expense, unpaid_amount: @outsourcing_cost.unpaid_amount }
    assert_redirected_to outsourcing_cost_path(assigns(:outsourcing_cost))
  end

  test "should destroy outsourcing_cost" do
    assert_difference('OutsourcingCost.count', -1) do
      delete :destroy, id: @outsourcing_cost
    end

    assert_redirected_to outsourcing_costs_path
  end
end
