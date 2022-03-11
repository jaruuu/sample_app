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

  describe "#follow" do
    let(:user) { create :user }
    let(:other_user) { create :user }

    it do
      expect(user.following?(other_user)).to be_falsey
      user.follow(other_user)
      expect(user.following?(other_user)).to be_truthy
    end
  end

  describe "#unfollow" do
    let(:user) { create :user }
    let(:other_user) { create :user }

    before { user.follow(other_user) }

    it do
      expect(user.following?(other_user)).to be_truthy
      user.unfollow(other_user)
      expect(user.following?(other_user)).to be_falsey
    end
  end

  describe "#following" do
    let(:user) { create :user }
    let(:followed_user) { create :user }
    let(:not_followed_user) { create :user }

    before { user.follow(followed_user) }

    it do
      expect(user.following?(followed_user)).to be_truthy
      expect(user.following?(not_followed_user)).to be_falsey
    end
  end

  describe "#feed" do
    let(:user) { create :user }
    let(:followed_user) { create :user }
    let(:not_followed_user) { create :user }

    before do
      user.follow(followed_user)
      create :micropost, user: user
      create :micropost, user: followed_user
      create :micropost, user: not_followed_user
    end

    it "display self and followed users posts" do
      include_posts = Micropost.where(user_id: [user.id, followed_user.id])
      not_include_posts = Micropost.where(user_id: not_followed_user.id)

      include_posts.each do |include_post|
        expect(user.feed).to include include_post
      end
      not_include_posts.each do |not_include_post|
        expect(user.feed).not_to include not_include_post
      end
    end
  end
end
