require "rails_helper"

describe Relationship, type: :model do
  describe "#validation" do
    subject { relationship }

    let(:relationship) { build(:relationship, follower_id: create(:user).id, followed_id: create(:user).id) }

    context "with normal atriibutes" do
      it { is_expected.to be_valid }
    end

    context "without follower_id" do
      it do
        relationship.follower_id = nil
        is_expected.to be_invalid
      end
    end

    context "without followed_id" do
      it do
        relationship.followed_id = nil
        is_expected.to be_invalid
      end
    end
  end
end
