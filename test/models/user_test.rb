require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      name: "Example User",
      email: "user@example.com",
      password: "passw0rd",
      password_confirmation: "passw0rd"
    )
  end

  test "shoudl be valid" do
    assert @user.valid?
  end

  test "name should be" do
    @user.name = "   "
    assert_not @user.valid?
  end

  test "email should be" do
    @user.email = "   "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 256
    assert_not @user.valid?
  end

  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email should be unique" do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test "email should be downcase before save" do
    mixed_case_email = "UsEr@examPlE.cOm"
    @user.email = mixed_case_email
    @user.save
    assert_equal @user.reload.email, mixed_case_email.downcase
  end

  test "password should be present(not blank)" do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test "password should be long than 6 characters" do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test "associated microposts should be destroy" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference "Micropost.count", -1 do
      @user.destroy
    end
  end

  test ".authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "follow an user" do
    michael = users(:michael)
    archer = users(:archer)
    assert_not michael.following?(archer)

    michael.follow(archer)
    assert michael.following?(archer)
    assert archer.followers.include?(michael)
  end

  test "unfollow an user" do
    michael = users(:michael)
    archer = users(:archer)
    Relationship.create!(follower_id: michael.id, followed_id: archer.id)
    assert michael.following?(archer)

    michael.unfollow(archer)
    assert_not michael.following?(archer)
  end

  test ".feed" do
    michael = users(:michael)
    lana = users(:lana)
    archer = users(:archer)

    # 自分自身の投稿
    michael.microposts.each do |self_micropost|
      assert michael.feed.include?(self_micropost)
    end
    # フォローしている人の投稿
    lana.microposts.each do |following_micropost|
      assert michael.feed.include?(following_micropost)
    end
    # フォローしていない人の投稿
    archer.microposts.each do |unfollow_micropost|
      assert_not michael.feed.include?(unfollow_micropost)
    end
  end
end
