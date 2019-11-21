require 'rails_helper'

RSpec.describe User, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:user)).to be_valid
  end

  describe '#email' do
    it 'is invalid without an email' do
      user = FactoryBot.build(:user, :email_empty)
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
      user = FactoryBot.build(:user, :password_empty)
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

  describe 'association' do
    it 'delete funds when deleted a user associated it' do
      user = FactoryBot.build(:user)
      user.funds << FactoryBot.build(:fund)
      user.save
      expect{ user.destroy }.to change(Fund, :count).by(-1)
    end

    it 'delete ratios when deleted a user associated it' do
      user = FactoryBot.build(:user)
      user.ratios << FactoryBot.build(:ratio)
      user.save
      expect{ user.destroy }.to change(Ratio, :count).by(-1)
    end
  end
end
