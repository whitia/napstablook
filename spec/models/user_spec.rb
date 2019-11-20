require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:user)).to be_valid
  end

  it 'is valid with an email and password' do
    user = FactoryBot.build(:user)
    expect(user).to be_valid
  end
  
  describe '#emal' do
    it 'is invalid without an email' do
      user = FactoryBot.build(:user, email: nil)
      user.valid?
      expect(user.errors[:email]).to include('can\'t be blank')
    end
  
    it 'is invalid with a duplicate email' do
      FactoryBot.create(:user, email: 'test@example.com')
      user = FactoryBot.build(:user, email: 'test@example.com')
      user.valid?
      expect(user.errors[:email]).to include('has already been taken')
    end

    it 'is invalid without a true format email' do
      user = FactoryBot.build(:user, email: 'testexamplecom')
      user.valid?
      expect(user.errors[:email]).to include('is invalid')
    end
  end
  
  describe '#password' do
    it 'is invalid without a password' do
      user = User.new(password: nil, password_confirmation: nil)
      user.valid?
      expect(user.errors[:password]).to include('can\'t be blank')
    end
  
    it 'is valid with a password length is 6 characters' do
      user = FactoryBot.build(:user, password: '123456', password_confirmation: '123456')
      user.valid?
      expect(user).to be_valid
    end
  
    it 'is invalid with a password length is 5 characters' do
      user = FactoryBot.build(:user, password: '12345', password_confirmation: '12345')
      user.valid?
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end
  end
end
