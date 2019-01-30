require 'test_helper'

class ConstructionAttachmentsControllerTest < ActionController::TestCase
  setup do
    @construction_attachment = construction_attachments(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:construction_attachments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create construction_attachment" do
    assert_difference('ConstructionAttachment.count') do
      post :create, construction_attachment: { attachment: @construction_attachment.attachment, construction_datum_id: @construction_attachment.construction_datum_id, title: @construction_attachment.title }
    end

    assert_redirected_to construction_attachment_path(assigns(:construction_attachment))
  end

  test "should show construction_attachment" do
    get :show, id: @construction_attachment
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @construction_attachment
    assert_response :success
  end

  test "should update construction_attachment" do
    patch :update, id: @construction_attachment, construction_attachment: { attachment: @construction_attachment.attachment, construction_datum_id: @construction_attachment.construction_datum_id, title: @construction_attachment.title }
    assert_redirected_to construction_attachment_path(assigns(:construction_attachment))
  end

  test "should destroy construction_attachment" do
    assert_difference('ConstructionAttachment.count', -1) do
      delete :destroy, id: @construction_attachment
    end

    assert_redirected_to construction_attachments_path
  end
end
