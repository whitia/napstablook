class FundsController < ApplicationController
  def index
    @user_id = params[:user_id]

    # Funds
    @funds = Fund.where(user_id: params[:user_id]).order('account DESC')

    # Summaries
    @sum = Hash.new
    @sum['買付金額'] = 0
    @sum['評価金額'] = 0
    @funds.each do |fund|
      @sum['買付金額'] += fund.purchase
      @sum['評価金額'] += fund.valuation
    end
    @sum['評価損益'] = @sum['評価金額'] - @sum['買付金額']

    # Ratios
    @assets = Hash.new { |h,k| h[k] = {} }
    Category.all.each do |category|
      @assets[category.name][:買付金額] = @funds.where(category: category.name).sum('purchase')
      @assets[category.name][:評価金額] = @funds.where(category: category.name).sum('valuation')
      @assets[category.name][:評価損益] = @assets[category.name][:評価金額] - @assets[category.name][:買付金額]
      
      purchase = @assets[category.name][:評価金額]
      ratio = Ratio.where(user_id: params[:user_id], category: category.name)
      @assets[category.name][:実際比率] = 0 < purchase ? (purchase.to_f / @sum['評価金額'].to_f * 100).round(3) : 0
      @assets[category.name][:目標比率] = ratio.exists? ? ratio.first.value : 0
      @assets[category.name][:比率差分] = (@assets[category.name][:実際比率] - @assets[category.name][:目標比率]).round(3)
    end

  end
  
  def import
    # Import
    funds = Array.new
    CSV.foreach(params[:file].path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      funds << Fund.new(name: row['ファンド名'],
                        category: nil,
                        account: row['口座種別'],
                        purchase: row['買付金額'],
                        valuation: row['評価金額'],
                        user_id: params[:user_id])
    end
    # Copy category from current to new if exists fund
    funds.each do |row|
      fund = Fund.where(user_id: params[:user_id])
                 .where(name: row.name)
                 .where(account: row.account)
                 .where.not(category: nil)
      if fund.count > 0
        row.category = Fund.fund.first.category
      end
    end
    # Delete current user's all columns
    Fund.where(user_id: params[:user_id]).destroy_all
    Fund.import(funds)

    @funds = Fund.where(user_id: params[:user_id]).order('account DESC')
    redirect_to user_funds_path
  end

  def set_category
    fund = Fund.find(params[:id])
    fund.update(category: (params[:category] == '' ? nil : params[:category]))
  end

  def set_ratio
    ratio = Ratio.where(user_id: params[:user_id], category: params[:category])
    if ratio.count > 0
      ratio.update(value: params[:value])
    else
      Ratio.create(user_id: params[:user_id], category: params[:category], value: params[:value])
    end
  end

end
