class FundsController < ApplicationController
  def index
    @funds = Fund.where(user_id: params[:user_id]).order('account DESC')
  end
  
  def new
  end

  def import
    Fund.where(user_id: params[:user_id]).destroy_all
    funds = []
    CSV.foreach(params[:file].path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      funds << Fund.new(name: row['ファンド名'],
                              category: nil,
                              account: row['口座種別'],
                              purchase: row['買付金額'],
                              valuation: row['評価金額'],
                              user_id: params[:user_id])
    end
    Fund.import(funds)
    @funds = Fund.where(user_id: params[:user_id]).order('account DESC')
    redirect_to user_funds_path
  end
end
