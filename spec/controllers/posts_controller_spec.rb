# frozen_string_literal: true

require "rails_helper"

RSpec.describe PostsController, type: :controller do
  let(:user) { create(:user) }

  before { session[:user_id] = user.id }

  describe "POST #create" do
    it "succeeds with blank brewing_method" do
      expect do
        post :create, params: { post: { body: "hello world", brewing_method: "" } }
      end.to change(Post, :count).by(1)
      expect(response).to redirect_to(feed_path)
    end

    it "succeeds with valid brewing_method" do
      expect do
        post :create, params: { post: { body: "hello world", brewing_method: "espresso" } }
      end.to change(Post, :count).by(1)
      expect(response).to redirect_to(feed_path)
    end

    it "fails with invalid brewing_method" do
      expect do
        post :create, params: { post: { body: "hello world", brewing_method: "invalid" } }
      end.not_to change(Post, :count)
      expect(response).to redirect_to(feed_path)
    end
  end
end
