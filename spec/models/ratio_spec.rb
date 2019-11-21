require 'rails_helper'

RSpec.describe Ratio, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.create(:ratio)).to be_valid
  end

  it 'is associated user when created ratio' do
    expect(FactoryBot.build(:ratio).user_id).to eq 1
  end
end
