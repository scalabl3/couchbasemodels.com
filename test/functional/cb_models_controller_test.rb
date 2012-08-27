require 'test_helper'

class CbModelsControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get product_catalog" do
    get :product_catalog
    assert_response :success
  end

  test "should get activity_stream" do
    get :activity_stream
    assert_response :success
  end

end
