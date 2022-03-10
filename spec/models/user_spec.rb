require "rails_helper.rb"

describe User, type: :model do
  describe "#validation" do
    let(:user) { build(:user) }

    context "with the normal attirbutes" do
      it { expect(user).to be_valid }
    end

    context "without name" do
      it do
        user.name = ""
        expect(user).to be_invalid
      end
    end
  end
end
