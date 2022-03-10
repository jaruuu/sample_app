require "rails_helper"

describe "StaticPages", type: :request do
  subject { response }

  describe "#home" do
    # TODO: あとで追加する
    # context "logged in user" do
    # end

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
