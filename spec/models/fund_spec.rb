require 'rails_helper'

RSpec.describe Fund, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:fund)).to be_valid
  end

  it 'is associated user when created fund' do
    expect(FactoryBot.build(:fund).user_id).to eq 1
  end
end
