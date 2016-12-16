require 'test_helper'

class ConstructionDailyReportsControllerTest < ActionController::TestCase
  setup do
    @construction_daily_report = construction_daily_reports(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:construction_daily_reports)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create construction_daily_report" do
    assert_difference('ConstructionDailyReport.count') do
      post :create, construction_daily_report: { construction_datum_id: @construction_daily_report.construction_datum_id, end_time_1: @construction_daily_report.end_time_1, end_time_2: @construction_daily_report.end_time_2, labor_cost: @construction_daily_report.labor_cost, man_month: @construction_daily_report.man_month, staff_id: @construction_daily_report.staff_id, start_time_1: @construction_daily_report.start_time_1, start_time_2: @construction_daily_report.start_time_2, working_date: @construction_daily_report.working_date, working_times: @construction_daily_report.working_times }
    end

    assert_redirected_to construction_daily_report_path(assigns(:construction_daily_report))
  end

  test "should show construction_daily_report" do
    get :show, id: @construction_daily_report
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @construction_daily_report
    assert_response :success
  end

  test "should update construction_daily_report" do
    patch :update, id: @construction_daily_report, construction_daily_report: { construction_datum_id: @construction_daily_report.construction_datum_id, end_time_1: @construction_daily_report.end_time_1, end_time_2: @construction_daily_report.end_time_2, labor_cost: @construction_daily_report.labor_cost, man_month: @construction_daily_report.man_month, staff_id: @construction_daily_report.staff_id, start_time_1: @construction_daily_report.start_time_1, start_time_2: @construction_daily_report.start_time_2, working_date: @construction_daily_report.working_date, working_times: @construction_daily_report.working_times }
    assert_redirected_to construction_daily_report_path(assigns(:construction_daily_report))
  end

  test "should destroy construction_daily_report" do
    assert_difference('ConstructionDailyReport.count', -1) do
      delete :destroy, id: @construction_daily_report
    end

    assert_redirected_to construction_daily_reports_path
  end
end
