require 'test_helper'

class EndpointControllerTest < ActionController::TestCase
  test "should get resp" do
    get :resp
    assert_response :success
  end

end
