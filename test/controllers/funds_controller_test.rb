require 'test_helper'

class FundsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get funds_new_url
    assert_response :success
  end

end
