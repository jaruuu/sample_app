require "rails_helper.rb"

describe User, type: :model do
  describe "#validation" do
    subject { user }

    let(:user) { build :user }

    context "with the normal attirbutes" do
      it { is_expected.to be_valid }
    end

    context "without name" do
      it do
        user.name = ""
        is_expected.to be_invalid
      end
    end

    context "without email" do
      it do
        user.email = ""
        is_expected.to be_invalid
      end
    end

    context "with a too long name" do
      it do
        user.name = "a" * 51
        is_expected.to be_invalid
      end
    end

    context "with a too long email" do
      it do
        user.name = "a" * 245 + "@sample.com"
        is_expected.to be_invalid
      end
    end

    context "with an invalid address" do
      let(:invalid_addresses) {
        %w[user@example,com user_at_foo.org user.name@example.
          foo@bar_baz.com foo@bar+baz.com foo@bar..com]
      }

      it do
        invalid_addresses.each do |invalid_address|
          user.email = invalid_address
          is_expected.to be_invalid
        end
      end
    end

    context "with a duplicate email" do
      let(:other_user) { create :user }

      it do
        user.email = other_user.email
        is_expected.to be_invalid
      end
    end

    context "without password" do
      it do
        user.password = user.password_confirmation = ' ' * 6
        is_expected.to be_invalid
      end
    end

    context "with a too short password" do
      it do
        user.password = user.password_confirmation = 'a' * 5
        is_expected.to be_invalid
      end
    end
  end

  describe "#callback" do
    let(:user) { build :user }

    context "replace email to downcase before save" do
      it do
        mixed_case_email = "UsEr@examPlE.cOm"
        user.email = mixed_case_email
        user.save

        expect(user.reload.email).to eq mixed_case_email.downcase
      end
    end

    context "create an activation digest before create" do
      it do
        expect(user.activation_digest).to be_nil
        user.save

        expect(user.reload.activation_digest).to be_truthy
      end
    end
  end

  describe "#association" do
    let(:user) { create :user }

    context "destroy microposts when destroy the user" do
      before { create(:micropost, user: user) }

      it do
        expect{ user.destroy }.to change(Micropost, :count).by(-1)
      end
    end
  end
end
