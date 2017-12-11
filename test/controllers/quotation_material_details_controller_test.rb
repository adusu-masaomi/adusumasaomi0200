require 'test_helper'

class QuotationMaterialDetailsControllerTest < ActionController::TestCase
  setup do
    @quotation_material_detail = quotation_material_details(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:quotation_material_details)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create quotation_material_detail" do
    assert_difference('QuotationMaterialDetail.count') do
      post :create, quotation_material_detail: { list_price: @quotation_material_detail.list_price, mail_sent_flag: @quotation_material_detail.mail_sent_flag, maker_id: @quotation_material_detail.maker_id, maker_name: @quotation_material_detail.maker_name, material_code: @quotation_material_detail.material_code, material_id: @quotation_material_detail.material_id, material_name: @quotation_material_detail.material_name, quantity: @quotation_material_detail.quantity, quotation_material_header_id: @quotation_material_detail.quotation_material_header_id, unit_master_id: @quotation_material_detail.unit_master_id }
    end

    assert_redirected_to quotation_material_detail_path(assigns(:quotation_material_detail))
  end

  test "should show quotation_material_detail" do
    get :show, id: @quotation_material_detail
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @quotation_material_detail
    assert_response :success
  end

  test "should update quotation_material_detail" do
    patch :update, id: @quotation_material_detail, quotation_material_detail: { list_price: @quotation_material_detail.list_price, mail_sent_flag: @quotation_material_detail.mail_sent_flag, maker_id: @quotation_material_detail.maker_id, maker_name: @quotation_material_detail.maker_name, material_code: @quotation_material_detail.material_code, material_id: @quotation_material_detail.material_id, material_name: @quotation_material_detail.material_name, quantity: @quotation_material_detail.quantity, quotation_material_header_id: @quotation_material_detail.quotation_material_header_id, unit_master_id: @quotation_material_detail.unit_master_id }
    assert_redirected_to quotation_material_detail_path(assigns(:quotation_material_detail))
  end

  test "should destroy quotation_material_detail" do
    assert_difference('QuotationMaterialDetail.count', -1) do
      delete :destroy, id: @quotation_material_detail
    end

    assert_redirected_to quotation_material_details_path
  end
end
