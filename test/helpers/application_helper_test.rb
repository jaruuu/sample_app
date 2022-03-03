require 'test_helper'

class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    base_title = 'Ruby on Rails Tutorial Sample App'
    page_title = "Help"

    assert_equal full_title, base_title
    assert_equal full_title(page_title), "#{page_title} | #{base_title}"
  end
end
