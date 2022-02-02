require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "failed updating user with invalid information" do
    get edit_user_path(@user)
    assert_template "users/edit"

    patch user_path(@user), params: { user: { name: "", email: @user.name, password: "invalid" } }
    assert_template "users/edit"
    assert_select "form div#error_explanation div.alert"
    assert_select "form div#error_explanation ul li", count: 2
  end

  test "success updating user with valid information" do
    get edit_user_path(@user)
    assert_template "users/edit"

    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name: name, email: email, password: "", password_confirmation: "" } }

    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload
    assert_equal name, @user.name
    assert_equal email, @user.email
  end
end
