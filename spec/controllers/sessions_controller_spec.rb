require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
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
    before do
      @user = FactoryBot.create(:user)
    end

    context 'with valid attributes' do
      it 'adds a session (login)' do
        expect{
          post :create, params: { email: @user.email, password: @user.password }
        }.to change{ current_user }.from(nil)
      end

      it 'returns a 302 response' do
        post :create, params: { email: @user.email, password: @user.password }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the user page' do
        post :create, params: { email: @user.email, password: @user.password }
        expect(response).to redirect_to user_path(current_user.id)
      end
    end

    context 'with invalid attributes' do
      it 'does not add a session (login)' do
        expect{
          post :create, params: { email: @user.email, password: 'invalid-password' }
        }.to_not change{ current_user }
      end

      it 'returns a 302 response' do
        post :create, params: { email: @user.email, password: 'invalid-password' }
        expect(response).to have_http_status '302'
      end

      it 'redirects to the root' do
        post :create, params: { email: @user.email, password: 'invalid-password' }
        expect(response).to redirect_to root_path
      end
    end
  end

  describe '#destroy' do
    before do
      @user = FactoryBot.create(:user)
    end

    it 'deletes a session (logout)' do
      log_in @user
      expect{
        delete :destroy, params: { id: @user.id }
      }.to change{ current_user }.to(nil)
    end

    it 'returns a 302 response' do
        delete :destroy, params: { id: @user.id }
      expect(response).to have_http_status '302'
    end

    it 'redirects to the root' do
        delete :destroy, params: { id: @user.id }
      expect(response).to redirect_to root_path
    end
  end
end
