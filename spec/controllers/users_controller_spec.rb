require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  describe '#show' do
    context 'as an authenticated user' do
      before do
        @user = FactoryBot.create(:user)
      end
  
      it 'responds successfully' do
        log_in @user
        get :show, params: { id: @user.id }
        expect(response).to be_successful
      end
    end

    context 'as a guest' do
      before do
        @user = FactoryBot.create(:user)
      end

      it 'returns a 302 response' do
        get :show, params: { id: @user.id }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the log-in page' do
        get :show, params: { id: @user.id }
        expect(response).to redirect_to new_session_path
      end
    end

    context ' as an unauthorized user' do
      before do
        @user1 = FactoryBot.create(:user)
        @user2 = FactoryBot.create(:user)
      end

      it 'returns a 302 response' do
        log_in @user1
        get :show, params: { id: @user2.id }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the root' do
        log_in @user1
        get :show, params: { id: @user2.id }
        expect(response).to redirect_to root_path
      end
    end
  end
  
  describe '#new' do
    it 'responds successfully' do
      get :new
      expect(response).to be_successful
    end

    it 'returns a 200 response' do
      get :new
      expect(response).to have_http_status '200'
    end
  end

  describe '#create' do
    it 'adds a user' do
      expect{
        post :create, params: { user: FactoryBot.attributes_for(:user) }
      }.to change(User, :count).by(1)
    end

    it 'returns a 302 response' do
      post :create, params: { user: FactoryBot.attributes_for(:user) }
      expect(response).to have_http_status '302'
    end

    it 'redirects to the user page' do
      post :create, params: { user: FactoryBot.attributes_for(:user) }
      expect(response).to redirect_to user_path(current_user.id)
    end
  end

  describe '#destroy' do
    describe 'as an authenticated user' do
      before do
        @user = FactoryBot.create(:user)
      end

      it 'deletes a user' do
        log_in @user
        expect{
          delete :destroy, params: { id: @user.id }
        }.to change(User, :count).by(-1)
      end

      it 'returns a 302 response' do
        log_in @user
        delete :destroy, params: { id: @user.id }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the root' do
        log_in @user
        delete :destroy, params: { id: @user.id }
        expect(response).to redirect_to root_path
      end
    end

    describe 'as a guest' do
      before do
        @user = FactoryBot.create(:user)
      end

      it 'doesn\'t delete a user' do
        expect{
          delete :destroy, params: { id: @user.id }
        }.to change(User, :count).by(0)
      end

      it 'returns a 302 response' do
        get :show, params: { id: @user.id }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the log-in page' do
        get :show, params: { id: @user.id }
        expect(response).to redirect_to new_session_path
      end
    end

    describe 'as an unauthorized user' do
      before do
        @user1 = FactoryBot.create(:user)
        @user2 = FactoryBot.create(:user)
      end

      it 'doesn\'t delete a user' do
        log_in @user1
        delete :destroy, params: { id: @user2.id }
        expect(response).to redirect_to root_path
      end

      it 'returns a 302 response' do
        log_in @user1
        get :show, params: { id: @user2.id }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the root' do
        log_in @user1
        get :show, params: { id: @user2.id }
        expect(response).to redirect_to root_path
      end
    end
  end
end
