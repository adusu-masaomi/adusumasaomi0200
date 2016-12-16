require 'test_helper'

class CustomerMastersControllerTest < ActionController::TestCase
  setup do
    @customer_master = customer_masters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:customer_masters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create customer_master" do
    assert_difference('CustomerMaster.count') do
      post :create, customer_master: { address: @customer_master.address, closing_date: @customer_master.closing_date, customer_name: @customer_master.customer_name, due_date: @customer_master.due_date, email_main: @customer_master.email_main, fax_main: @customer_master.fax_main, post: @customer_master.post, responsible1: @customer_master.responsible1, responsible2: @customer_master.responsible2, tel_main: @customer_master.tel_main }
    end

    assert_redirected_to customer_master_path(assigns(:customer_master))
  end

  test "should show customer_master" do
    get :show, id: @customer_master
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @customer_master
    assert_response :success
  end

  test "should update customer_master" do
    patch :update, id: @customer_master, customer_master: { address: @customer_master.address, closing_date: @customer_master.closing_date, customer_name: @customer_master.customer_name, due_date: @customer_master.due_date, email_main: @customer_master.email_main, fax_main: @customer_master.fax_main, post: @customer_master.post, responsible1: @customer_master.responsible1, responsible2: @customer_master.responsible2, tel_main: @customer_master.tel_main }
    assert_redirected_to customer_master_path(assigns(:customer_master))
  end

  test "should destroy customer_master" do
    assert_difference('CustomerMaster.count', -1) do
      delete :destroy, id: @customer_master
    end

    assert_redirected_to customer_masters_path
  end
end
