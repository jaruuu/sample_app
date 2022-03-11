require "rails_helper"

describe Micropost, type: :model do
  describe "#validation" do
    subject { micropost }

    let(:micropost) { build :micropost, user: create(:user) }

    context "with the normal attributes" do
      it { is_expected.to be_valid }
    end

    context "without user_id" do
      it do
        micropost.user_id = nil
        is_expected.to be_invalid
      end
    end

    context "without content" do
      it do
        micropost.content = ""
        is_expected.to be_invalid
      end
    end

    context "with too long content" do
      it do
        micropost.content = "a" * 141
        is_expected.to be_invalid
      end
    end
  end

  describe "#default_scope" do
    let(:latest) { create :micropost, created_at: Time.zone.today }
    let(:middle) { create :micropost, created_at: Time.zone.today - 1 }
    let(:oldest) { create :micropost, created_at: Time.zone.today - 2 }

    it { expect(Micropost.all).to match_array [latest, middle, oldest] }
  end
end
