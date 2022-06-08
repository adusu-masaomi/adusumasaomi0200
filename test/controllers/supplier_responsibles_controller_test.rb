require 'test_helper'

class SupplierResponsiblesControllerTest < ActionController::TestCase
  setup do
    @supplier_responsible = supplier_responsibles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:supplier_responsibles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create supplier_responsible" do
    assert_difference('SupplierResponsible.count') do
      post :create, supplier_responsible: { responsible_email: @supplier_responsible.responsible_email, responsible_name: @supplier_responsible.responsible_name, supplier_master_id: @supplier_responsible.supplier_master_id }
    end

    assert_redirected_to supplier_responsible_path(assigns(:supplier_responsible))
  end

  test "should show supplier_responsible" do
    get :show, id: @supplier_responsible
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @supplier_responsible
    assert_response :success
  end

  test "should update supplier_responsible" do
    patch :update, id: @supplier_responsible, supplier_responsible: { responsible_email: @supplier_responsible.responsible_email, responsible_name: @supplier_responsible.responsible_name, supplier_master_id: @supplier_responsible.supplier_master_id }
    assert_redirected_to supplier_responsible_path(assigns(:supplier_responsible))
  end

  test "should destroy supplier_responsible" do
    assert_difference('SupplierResponsible.count', -1) do
      delete :destroy, id: @supplier_responsible
    end

    assert_redirected_to supplier_responsibles_path
  end
end
