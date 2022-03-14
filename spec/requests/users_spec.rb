require "rails_helper"

describe "Users", type: :request do
  describe "#index" do
    context "by not logged in user" do
      it do
        get users_path
        expect(response).to have_http_status 302
      end
    end

    context "by logged in user" do
      let(:user) { create(:user) }
      let(:unactivated_user) { create(:user, :with_micropost) }

      before { log_in_as(user) }

      it do
        get users_path
        expect(response).to have_http_status :ok
        expect(assigns(:users)).to include user
        expect(assigns(:users)).not_to include unactivated_user
      end
    end
  end

  describe "#show" do
    context "to activated user by not logged in user" do
      let(:user) { create(:user) }

      it do
        get user_path(user)
        expect(response).to have_http_status 302
      end
    end

    context "to unactivated user by logged in user" do
      let(:user) { create(:user, :unactivated) }

      before { log_in_as(create(:user)) }

      it do
        get user_path(user)
        expect(assigns(:user)).to eq user
        expect(response).to have_http_status 302
      end
    end

    context "to activated user by logged in user" do
      let(:user) { create(:user, :with_micropost) }

      before { log_in_as(create(:user)) }

      it do
        get user_path(user)
        expect(response).to have_http_status :ok
        expect(assigns(:user)).to eq user
        expect(assigns(:microposts)).to eq user.microposts.paginate(page: 1)
      end
    end
  end

  describe "#new" do
    it do
      get new_user_path
      expect(response).to have_http_status :ok
    end
  end

  describe "#create" do
    context "succeed with normal params" do
      let(:params) { { name: "John", email: "john@example.com", password: "foobar", password_confirmation: "foobar" } }
      it do
        post users_path, params: { user: params }

        expect(assigns(:user)).to have_attributes(params)
        expect(flash[:info]).to be_truthy
        expect(response).to have_http_status 302
      end
    end

    context "failed with abnormal params" do
      let(:params) { { name: "John", email: "john@example.com", password: "foobar", password_confirmation: "foo" } }

      it do
        post users_path, params: { user: params }
        expect(assigns(:user)).to have_attributes(params)
        expect(response).to have_http_status :ok
        expect(response).to render_template :new
      end
    end
  end

  describe "#edit" do
    context "redirect by not logged in correct user" do
      let(:user) { create(:user) }

      it do
        get edit_user_path(user)
        expect(response).to have_http_status 302
      end
    end

    context "redirect by logged in uncorrect user" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before { log_in_as(other_user) }

      it do
        get edit_user_path(user)
        expect(response).to have_http_status 302
      end
    end

    context "succeed by logged in correct user" do
      let(:user) { create(:user) }

      before { log_in_as(user) }

      it do
        get edit_user_path(user)
        expect(assigns(:user)).to eq user
        expect(response).to have_http_status :ok
      end
    end
  end

  describe "#update" do
    context "redirect by not logged in correct user" do
      let(:user) { create(:user) }

      it do
        patch user_path(user), params: { user: { name: "Mike" } }
        expect(response).to have_http_status 302
      end
    end

    context "redirect by logged in uncorrect user" do
      let(:user) { create(:user) }
      let(:other_user) { create(:user) }

      before { log_in_as(other_user) }

      it do
        patch user_path(user), params: { user: { name: "Mike" } }
        expect(response).to have_http_status 302
      end
    end

    context "succeed with normal params" do
      let(:user) { create(:user) }
      let(:name) { "Mike" }

      before { log_in_as(user) }

      it do
        patch user_path(user), params: { user: { name: name } }
        expect(flash[:success]).to be_truthy
        expect(response).to have_http_status 302
        expect(user.reload.name).to eq name
      end
    end

    context "failed with abnormal params" do
      let(:user) { create(:user) }

      before { log_in_as(user) }

      it do
        patch user_path(user), params: { user: { name: "" } }
        expect(response).to render_template(:edit)
      end
    end

    context "failed with unpermitted params" do
      let(:user) { create(:user) }

      before { log_in_as(user) }

      it do
        patch user_path(user), params: { user: { admin: true } }
        expect(response).to have_http_status 302
        expect(user.reload.admin).to eq false
      end
    end
  end

  describe "#destroy" do
    context "redirect by not logged in user" do
      let!(:user) { create(:user) }

      it do
        expect { delete user_path(user) }.to change(User, :count).by(0)
        expect(response).to have_http_status 302
      end
    end

    context "redirect by logged in non-admin user" do
      let(:user) { create(:user) }
      let!(:other_user) { create(:user) }

      before { log_in_as(user) }

      it do
        expect { delete user_path(other_user) }.to change(User, :count).by(0)
        expect(response).to have_http_status 302
      end
    end

    context "succeed to a noraml user by logged in admin user" do
      let(:admin) { create(:user, :admin) }
      let!(:other_user) { create(:user) }

      before { log_in_as(admin) }

      it do
        expect { delete user_path(other_user) }.to change(User, :count).by(-1)
        expect(flash[:success]).to be_truthy
        expect(response).to have_http_status 302
      end
    end
  end

  describe "#following" do
    context "by not logged in user" do
      let(:user) { create(:user) }

      it do
        get following_user_path(user)
        expect(response).to have_http_status 302
      end
    end

    context "by logged in user" do
      let(:user) { create(:user) }

      before do
        log_in_as(user)
        create(:relationship, follower_id: user.id, followed_id: create(:user).id)
      end

      it do
        get following_user_path(user)
        expect(assigns(:title)).to eq "Following"
        expect(assigns(:user)).to eq user
        expect(assigns(:users)).to eq user.following.paginate(page: 1)
        expect(response).to render_template("show_follow")
      end
    end
  end

  describe "#followers" do
    context "by not logged in user" do
      let(:user) { create(:user) }

      it do
        get followers_user_path(user)
        expect(response).to have_http_status 302
      end
    end

    context "by logged in user" do
      let(:user) { create(:user) }

      before do
        log_in_as(user)
        create(:relationship, follower_id: user.id, followed_id: create(:user).id)
      end

      it do
        get followers_user_path(user)
        expect(assigns(:title)).to eq "Followers"
        expect(assigns(:user)).to eq user
        expect(assigns(:users)).to eq user.followers.paginate(page: 1)
        expect(response).to render_template("show_follow")
      end
    end
  end
end
