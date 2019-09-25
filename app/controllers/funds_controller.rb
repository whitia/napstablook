class FundsController < ApplicationController
  def index
    @funds = Fund.where(user_id: params[:user_id]).order('account DESC')

    @sum_purchase = 0
    @funds.each do |fund|
      @sum_purchase += fund.purchase
    end

    @sum_valuation = 0
    @funds.each do |fund|
      @sum_valuation += fund.valuation
    end
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

  def set_category
    fund = Fund.find(params[:id])
    fund.update(category: params[:category])
    render json: { status: 'success' }
  end

end
