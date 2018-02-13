require 'test_helper'

class TasksControllerTest < ActionController::TestCase
  setup do
    @task = tasks(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:tasks)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create task" do
    assert_difference('Task.count') do
      post :create, task: { construction_datum_id: @task.construction_datum_id, duration: @task.duration, end_date: @task.end_date, parent: @task.parent, progress: @task.progress, sortorder: @task.sortorder, start_date: @task.start_date, text: @task.text, work_end_date: @task.work_end_date, work_start_date: @task.work_start_date }
    end

    assert_redirected_to task_path(assigns(:task))
  end

  test "should show task" do
    get :show, id: @task
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @task
    assert_response :success
  end

  test "should update task" do
    patch :update, id: @task, task: { construction_datum_id: @task.construction_datum_id, duration: @task.duration, end_date: @task.end_date, parent: @task.parent, progress: @task.progress, sortorder: @task.sortorder, start_date: @task.start_date, text: @task.text, work_end_date: @task.work_end_date, work_start_date: @task.work_start_date }
    assert_redirected_to task_path(assigns(:task))
  end

  test "should destroy task" do
    assert_difference('Task.count', -1) do
      delete :destroy, id: @task
    end

    assert_redirected_to tasks_path
  end
end
