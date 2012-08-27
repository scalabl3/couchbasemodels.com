require 'test_helper'

class CbStrategiesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get organic" do
    get :organic
    assert_response :success
  end

  test "should get behavioral" do
    get :behavioral
    assert_response :success
  end

end
