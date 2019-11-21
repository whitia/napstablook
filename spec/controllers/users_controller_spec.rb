require 'rails_helper'

RSpec.describe UsersController, type: :controller do
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
