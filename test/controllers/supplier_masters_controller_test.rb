require 'test_helper'

class SupplierMastersControllerTest < ActionController::TestCase
  setup do
    @supplier_master = supplier_masters(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:supplier_masters)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create supplier_master" do
    assert_difference('SupplierMaster.count') do
      post :create, supplier_master: { email1: @supplier_master.email1, email2: @supplier_master.email2, email3: @supplier_master.email3, email_main: @supplier_master.email_main, fax_main: @supplier_master.fax_main, responsible1: @supplier_master.responsible1, responsible2: @supplier_master.responsible2, responsible3: @supplier_master.responsible3, supplier_name: @supplier_master.supplier_name, tel_main: @supplier_master.tel_main }
    end

    assert_redirected_to supplier_master_path(assigns(:supplier_master))
  end

  test "should show supplier_master" do
    get :show, id: @supplier_master
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @supplier_master
    assert_response :success
  end

  test "should update supplier_master" do
    patch :update, id: @supplier_master, supplier_master: { email1: @supplier_master.email1, email2: @supplier_master.email2, email3: @supplier_master.email3, email_main: @supplier_master.email_main, fax_main: @supplier_master.fax_main, responsible1: @supplier_master.responsible1, responsible2: @supplier_master.responsible2, responsible3: @supplier_master.responsible3, supplier_name: @supplier_master.supplier_name, tel_main: @supplier_master.tel_main }
    assert_redirected_to supplier_master_path(assigns(:supplier_master))
  end

  test "should destroy supplier_master" do
    assert_difference('SupplierMaster.count', -1) do
      delete :destroy, id: @supplier_master
    end

    assert_redirected_to supplier_masters_path
  end
end
