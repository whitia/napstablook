class FundsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    redirect_to root_path if !logged_in? || (current_user.id != params[:user_id].to_i)

    @funds = Fund.where(user_id: params[:user_id]).order('account DESC')

    # Categories
    @categories = Array.new
    @colors = Array.new
    Category.all.each do |category|
      @categories << category.name
      @colors << category.color
    end

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
      @assets[category.name][:評価金額] = @funds.where(category: category.name).sum('valuation') + \
                                         @funds.where(category: category.name).sum('increase')
      
      valuation = @assets[category.name][:評価金額]
      ratio = Ratio.where(user_id: params[:user_id], category: category.name)
      @assets[category.name][:実際比率] = 0 < valuation ? (valuation.to_f / @sum['評価金額'].to_f * 100).round(3) : 0
      @assets[category.name][:目標比率] = ratio.exists? ? ratio.first.value : 0.0
      @assets[category.name][:比率差分] = (@assets[category.name][:実際比率] - @assets[category.name][:目標比率]).round(3)
    end

    # Pie datas
    @real = Hash.new
    Category.all.each do |category|
      @real[category.name] = @assets[category.name][:実際比率]
    end

    @ideal = Hash.new
    Category.all.each do |category|
      @ideal[category.name] = @assets[category.name][:目標比率]
    end
  end
  
  def import
    # Import
    funds = Array.new
    CSV.foreach(params[:file].path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      funds << Fund.new(name: row['ファンド名'],
                        account: row['口座種別'],
                        purchase: row['買付金額'],
                        valuation: row['評価金額'],
                        difference: row['評価金額'].to_i - row['買付金額'].to_i,
                        category: nil,
                        increase: 0,
                        user_id: params[:user_id])
    end
    # Update new category to current it if exists fund
    funds.each do |row|
      fund = Fund.where(user_id: params[:user_id])
                 .where(name: row.name)
                 .where(account: row.account)
                 .where.not(category: nil)
      if fund.exists?
        row.category = fund.first.category
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
    before_category = fund.category
    after_category  = params[:category]
    fund.update(category: (after_category.present? ? after_category : nil))

    render json: get_ratios(fund, before_category, after_category)
  end

  def set_increase
    fund = Fund.find(params[:id])
    fund.update(increase: params[:increase])

    render json: get_ratios(fund, fund.category, fund.category)
  end

  def set_ratio
    ratio = Ratio.where(user_id: params[:user_id], category: params[:category])
    if ratio.exists?
      ratio.update(value: params[:value])
    else
      Ratio.create(user_id: params[:user_id], category: params[:category], value: params[:value])
    end
    render json: {
      category: params[:category],
      value: params[:value]
    }
  end

  private
    def get_ratios(fund, before_category, after_category)
      # Purchases
      before_purchase = Fund.where(user_id: fund.user_id, category: before_category).sum('purchase')
      after_purchase  = Fund.where(user_id: fund.user_id, category: after_category).sum('purchase')
  
      # Valuations
      before_valuation = Fund.where(user_id: fund.user_id, category: before_category).sum('valuation') + \
                         Fund.where(user_id: fund.user_id, category: before_category).sum('increase')
      after_valuation  = Fund.where(user_id: fund.user_id, category: after_category).sum('valuation') + \
                         Fund.where(user_id: fund.user_id, category: after_category).sum('increase')
      
      # Real ratios
      sum_valuation = Fund.where(user_id: fund.user_id).sum('valuation')
      before_real = 0 < before_valuation ? (before_valuation.to_f / sum_valuation.to_f * 100).round(3) : 0
      after_real  = 0 < after_valuation ? (after_valuation.to_f / sum_valuation.to_f * 100).round(3) : 0
  
      # Ideal ratios
      before_ratio = Ratio.where(user_id: fund.user_id, category: before_category)
      after_ratio  = Ratio.where(user_id: fund.user_id, category: after_category)
      before_ideal = before_ratio.exists? ? before_ratio.first.value : 0
      after_ideal  = after_ratio.exists? ? after_ratio.first.value : 0
      
      return {
        before: {
          category: before_category,
          purchase: before_purchase.to_s(:delimited),
          valuation: before_valuation.to_s(:delimited),
          real: before_real,
          diff: (before_real - before_ideal).round(3)
        },
        after: {
          category: after_category,
          purchase: after_purchase.to_s(:delimited),
          valuation: after_valuation.to_s(:delimited),
          real: after_real,
          diff: (after_real - after_ideal).round(3)
        }
      }
    end

end
