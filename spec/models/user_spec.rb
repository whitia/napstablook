require 'rails_helper'

RSpec.describe User, type: :model do
  it 'is valid with an email and password' do
    user = User.new(
      email: 'test@example.com',
      password: 'test-test',
      password_confirmation: 'test-test'
    )
    expect(user).to be_valid
  end

  it 'is invalid without an email' do
    user = User.new(email: nil)
    user.valid?
    expect(user.errors[:email]).to include('can\'t be blank')
  end

  it 'is invalid with a duplicate email' do
    User.create(
      email: 'test@example.com',
      password: 'test-test',
      password_confirmation: 'test-test'
    )
    user = User.new(
      email: 'test@example.com',
      password: 'test-test',
      password_confirmation: 'test-test'
    )
    user.valid?
    expect(user.errors[:email]).to include('has already been taken')
  end
end
