require 'test_helper'

class TaskContentsControllerTest < ActionController::TestCase
  setup do
    @task_content = task_contents(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:task_contents)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create task_content" do
    assert_difference('TaskContent.count') do
      post :create, task_content: { name: @task_content.name }
    end

    assert_redirected_to task_content_path(assigns(:task_content))
  end

  test "should show task_content" do
    get :show, id: @task_content
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @task_content
    assert_response :success
  end

  test "should update task_content" do
    patch :update, id: @task_content, task_content: { name: @task_content.name }
    assert_redirected_to task_content_path(assigns(:task_content))
  end

  test "should destroy task_content" do
    assert_difference('TaskContent.count', -1) do
      delete :destroy, id: @task_content
    end

    assert_redirected_to task_contents_path
  end
end
