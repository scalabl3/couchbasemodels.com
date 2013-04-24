require 'test_helper'

class CbIndexesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get anatomy" do
    get :anatomy
    assert_response :success
  end

  test "should get mr_examples" do
    get :mr_examples
    assert_response :success
  end

  test "should get elastic_search" do
    get :elastic_search
    assert_response :success
  end

end
