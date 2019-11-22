require 'rails_helper'

RSpec.feature "Users", type: :feature do
  scenario 'guest creates a new user (signup)' do
    user = FactoryBot.build(:user)

    visit root_path
    expect{
      click_link 'ユーザー登録（無料）'
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: user.password
      fill_in 'パスワード（確認）', with: user.password_confirmation
      click_button '登録'

      expect(page).to have_content user.email
    }.to change(User, :count).by(1)
  end
end
