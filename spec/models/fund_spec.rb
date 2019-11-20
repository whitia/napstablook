require 'rails_helper'

RSpec.describe Fund, type: :model do
  it 'has a valid factory' do
    expect(FactoryBot.build(:fund)).to be_valid
  end
end
