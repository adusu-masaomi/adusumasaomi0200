require 'test_helper'

class QuotationMaterialHeadersControllerTest < ActionController::TestCase
  setup do
    @quotation_material_header = quotation_material_headers(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_material_headers)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_material_header" do
    assert_difference('QuotationMaterialHeader.count') do
      post :create, quotation_material_header: { construction_datum_id: @quotation_material_header.construction_datum_id, quotation_code: @quotation_material_header.quotation_code, requested_date: @quotation_material_header.requested_date, responsible: @quotation_material_header.responsible, supplier_master_id: @quotation_material_header.supplier_master_id }
    end

    assert_redirected_to quotation_material_header_path(assigns(:quotation_material_header))
  end

  test "should show quotation_material_header" do
    get :show, id: @quotation_material_header
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_material_header
    assert_response :success
  end

  test "should update quotation_material_header" do
    patch :update, id: @quotation_material_header, quotation_material_header: { construction_datum_id: @quotation_material_header.construction_datum_id, quotation_code: @quotation_material_header.quotation_code, requested_date: @quotation_material_header.requested_date, responsible: @quotation_material_header.responsible, supplier_master_id: @quotation_material_header.supplier_master_id }
    assert_redirected_to quotation_material_header_path(assigns(:quotation_material_header))
  end

  test "should destroy quotation_material_header" do
    assert_difference('QuotationMaterialHeader.count', -1) do
      delete :destroy, id: @quotation_material_header
    end

    assert_redirected_to quotation_material_headers_path
  end
end
