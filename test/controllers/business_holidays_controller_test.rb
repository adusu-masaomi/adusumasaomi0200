require 'test_helper'

class BusinessHolidaysControllerTest < ActionController::TestCase
  setup do
    @business_holiday = business_holidays(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:business_holidays)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create business_holiday" do
    assert_difference('BusinessHoliday.count') do
      post :create, business_holiday: { holiday_flag: @business_holiday.holiday_flag, working_date: @business_holiday.working_date }
    end

    assert_redirected_to business_holiday_path(assigns(:business_holiday))
  end

  test "should show business_holiday" do
    get :show, id: @business_holiday
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @business_holiday
    assert_response :success
  end

  test "should update business_holiday" do
    patch :update, id: @business_holiday, business_holiday: { holiday_flag: @business_holiday.holiday_flag, working_date: @business_holiday.working_date }
    assert_redirected_to business_holiday_path(assigns(:business_holiday))
  end

  test "should destroy business_holiday" do
    assert_difference('BusinessHoliday.count', -1) do
      delete :destroy, id: @business_holiday
    end

    assert_redirected_to business_holidays_path
  end
end
