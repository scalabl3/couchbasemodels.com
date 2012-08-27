require 'test_helper'

class CbPatternsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get counter_id" do
    get :counter_id
    assert_response :success
  end

  test "should get lookup" do
    get :lookup
    assert_response :success
  end

end
