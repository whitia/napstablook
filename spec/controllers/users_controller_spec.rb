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
end
