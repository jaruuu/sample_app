require "rails_helper"

describe "StaticPages", type: :request do
  subject { response }

  describe "#home" do
    context "by logged in user" do
      let(:user) { create(:user, :with_micropost) }

      before { log_in_as(user) }

      it do
        get root_url
        is_expected.to have_http_status :ok
        expect(assigns(:micropost).user_id).to eq user.id
        expect(assigns(:feed_items)).to eq user.feed.paginate(page: 1)
      end
    end

    context "not logged in user" do
      it "should be access" do
        get root_url
        is_expected.to have_http_status :ok
      end
    end
  end

  describe "#help" do
    it "should be access" do
      get help_url
      is_expected.to have_http_status :ok
    end
  end

  describe "#about" do
    it "should be access" do
      get about_url
      is_expected.to have_http_status :ok
    end
  end

  describe "#contact" do
    it "should be access" do
      get contact_url
      is_expected.to have_http_status :ok
    end
  end
end
