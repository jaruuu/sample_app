require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "profile display in current_user" do
    log_in_as(@user)
    get user_path(@user)
    assert_template "users/show"
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_match @user.following.count.to_s, response.body
    assert_match @user.followers.count.to_s, response.body
    assert_select 'div#follow_form', count: 0
    assert_select 'div.pagination', count: 1
    @user.microposts.page(1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

  test "profile display in other_user" do
    log_in_as(@user)
    get user_path(@other_user)
    assert_select 'div#follow_form', count: 1
  end
end
