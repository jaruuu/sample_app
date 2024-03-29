require "test_helper"

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select "ul.pagination"
    assert_select "input[type=file]"
    # 無効な送信
    assert_no_difference "Micropost.count" do
      post microposts_path, params: { micropost: { content: "" } }
    end
    # エラーメッセージ
    assert_select "div#error_explanation"
    # 有効な送信
    content = "Hello world!"
    image = fixture_file_upload('test/fixtures/kitten.jpg', 'image/jpeg')
    assert_difference "Micropost.count", 1 do
      post microposts_path, params: { micropost: { content: content, image: image } }
    end
    assert @user.microposts.page(1).first.image.attached?
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body
    # 投稿を削除する
    assert_select "a", text: "delete"
    first_micropost = @user.microposts.page(1).first
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
