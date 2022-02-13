require "test_helper"

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear

    @user = users(:michael)
  end

  test "password resets" do
    get new_password_reset_path
    assert_template "password_resets/new"
    assert_select 'input[name=?]', 'password_reset[email]'
    # メールアドレスが無効
    post password_resets_path, params: { password_reset: { email: "invalid email" } }
    assert_template "password_resets/new"
    # メールアドレスが有効
    post password_resets_path, params: { password_reset: { email: @user.email } }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    user = assigns(:user)
    # トークンが無効
    get edit_password_reset_path("invald token", email: user.email)
    assert_redirected_to root_url
    # メールアドレスが無効
    get edit_password_reset_path(user.reset_token, email: "invalid email")
    assert_redirected_to root_url
    # ユーザーが有効化されていない
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # トークン、メールアドレスがともに有効
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template "password_resets/edit"
    assert_select "input[name=email][type=hidden][value=?]", user.email
    # 更新するパスワードが空
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "", password_confirmation: "" } }
    assert_select 'div#error_explanation'

    # 更新するパスワードが有効で、パスワード確認せと一致しない
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "passw0rd", password_confirmation: "foobar" } }
    assert_select 'div#error_explanation'

    # 更新するパスワードが有効で、パスワード確認せと一致する
    patch password_reset_path(user.reset_token), params: { email: user.email, user: { password: "passw0rd", password_confirmation: "passw0rd" } }
    assert is_logged_in?
    assert_not_equal user.reset_digest, user.reload.reset_digest
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, params: { password_reset: { email: @user.email } }

    @user = assigns(:user)
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token), params: { email: @user.email, user: { password: "passw0rd", password_confirmation: "passw0rd" } }
    assert_response :redirect
    follow_redirect!
    assert_match /expired/i, response.body
  end
end
