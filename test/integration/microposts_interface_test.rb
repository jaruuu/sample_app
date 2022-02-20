require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select "div.pagination"
    # 無効な送信
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    # エラーメッセージ
    assert_select "div#error_explanation"
    assert_select "a[href=?]", "/?page=2"
    # 有効な送信
    content = "Hello world!"
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference "Micropost.count", -1 do
      delete micropost_path(first_micropost)
    end
    # 違うユーザーのプロフィールからはmicropostを削除できない
    get user_path(users(:archer))
    assert_select 'a', text: "delete", count: 0
  end

  test "sidebar micropost count" do
    log_in_as(@user)
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
    other_user = users(:malory)
    log_in_as(other_user)
    get root_path
    # 以下 pluralize と count のテストをしているような気がする、、不要では？
    assert_match "0 microposts", response.body
    other_user.microposts.create!(content: "A micropost")
    get root_path
    assert_match "1 micropost", response.body
  end
end
