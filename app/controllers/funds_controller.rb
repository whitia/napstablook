class FundsController < ApplicationController
  before_action :require_login
  skip_before_action :verify_authenticity_token

  def index
    @funds = Fund.where(user_id: current_user.id).order('account desc, name desc')

    # Categories
    @categories = Array.new
    @colors = Array.new
    Category.all.each do |category|
      @categories << category.name
      @colors << category.color
    end

    # Summaries
    @sum = Hash.new
    @sum[:purchase] = 0
    @sum[:valuation] = 0
    @funds.each do |fund|
      @sum[:purchase] += fund.purchase
      @sum[:valuation] += fund.valuation
    end
    @sum[:difference] = @sum[:valuation] - @sum[:purchase]

    # Ratios
    @ratios = Hash.new { |h,k| h[k] = {} }
    Category.all.each do |category|
      ratio = Ratio.where(user_id: current_user.id, category: category.name)

      @ratios[category.name][:color] = category.color

      @ratios[category.name][:purchase] = @funds.where(category: category.name).sum(:purchase)
      @ratios[category.name][:valuation] = @funds.where(category: category.name).sum(:valuation) + \
                                           (ratio.present? ? (ratio.first.increase.nil? ? 0 : ratio.first.increase) : 0)

      valuation = @ratios[category.name][:valuation]
      @ratios[category.name][:increase] = (ratio.present? ? (ratio.first.increase.nil? ? 0 : ratio.first.increase) : 0)
      @ratios[category.name][:real] = 0 < valuation ? (valuation.to_f / @sum[:valuation].to_f * 100).round(3) : 0
      @ratios[category.name][:ideal] = ratio.present? ? ratio.first.value : 0.0
      @ratios[category.name][:difference] = (@ratios[category.name][:real] - @ratios[category.name][:ideal]).round(3)
    end

    # Pie charts
    @real = Hash.new
    Category.all.each do |category|
      @real[category.name] = @ratios[category.name][:real]
    end
    @ideal = Hash.new
    Category.all.each do |category|
      @ideal[category.name] = @ratios[category.name][:ideal]
    end
  end

  def import
    funds = Array.new
    CSV.foreach(params[:file].path, headers: true, encoding: 'Shift_JIS:UTF-8', force_quotes: true) do |row|
      funds << Fund.new(name: row['ファンド名'],
                        account: row['口座種別'],
                        purchase: row['買付金額'],
                        valuation: row['評価金額'],
                        difference: row['評価金額'].to_i - row['買付金額'].to_i,
                        category: nil,
                        user_id: current_user.id)
    end
    # Update new category to current it if exists fund
    funds.each do |row|
      fund = Fund.where(user_id: current_user.id)
                 .where(name: row.name)
                 .where(account: row.account)
                 .where.not(category: nil)
      if fund.exists?
        row.category = fund.first.category
      end
    end
    # Delete all columns of current user
    Fund.where(user_id: current_user.id).destroy_all
    # Bulk insert with activerecord-import
    Fund.import(funds)
    @funds = Fund.where(user_id: current_user.id).order('account desc, name desc')

    redirect_to funds_path
  end

  def set_category
    fund = Fund.find(params[:id])
    before_category = fund.category
    after_category = params[:category]
    fund.update(category: (after_category.present? ? after_category : nil))

    render json: get_ratios('Category', before_category, after_category), status: 200
  end

  def set_increase
    ratio = Ratio.where(user_id: current_user.id, category: params[:category])
    ratio.update(increase: params[:increase].empty? ? 0 : params[:increase])

    render json: get_ratios('Increase', params[:category], params[:category]), status: 200
  end

  def set_ideal
    ratio = Ratio.where(user_id: current_user.id, category: params[:category])
    if ratio.exists?
      ratio.update(value: params[:ideal])
    else
      Ratio.create(user_id: current_user.id, category: params[:category], value: params[:ideal])
    end

    ideal = Hash.new
    Category.all.each do |category|
      ratio = Ratio.where(user_id: current_user.id, category: category.name)
      ideal[category.name] = ratio.exists? ? ratio.first.value : 0.0
    end

    render json: {
      event: 'Ratio',
      category: params[:category],
      value: params[:ideal],
      ideal: ideal
    }
  end

  private
    def require_login
      redirect_to signin_path if !logged_in?
    end

    def get_ratios(event, before_category, after_category)
      # Purchases
      before_purchase = Fund.where(user_id: current_user.id, category: before_category).sum(:purchase)
      after_purchase = Fund.where(user_id: current_user.id, category: after_category).sum(:purchase)

      # Valuations
      before_ratio = Ratio.where(user_id: current_user.id, category: before_category)
      after_ratio = Ratio.where(user_id: current_user.id, category: after_category)
      before_valuation = Fund.where(user_id: current_user.id, category: before_category).sum(:valuation) + \
                         (before_ratio.present? ? (before_ratio.first.increase.nil? ? 0 : before_ratio.first.increase) : 0)
      after_valuation = Fund.where(user_id: current_user.id, category: after_category).sum(:valuation) + \
                        (after_ratio.present? ? (after_ratio.first.increase.nil? ? 0 : after_ratio.first.increase) : 0)

      # Real ratios
      sum_valuation = Fund.where(user_id: current_user.id).sum(:valuation) + Ratio.all.sum(:increase)
      before_real = 0 < before_valuation ? (before_valuation.to_f / sum_valuation.to_f * 100).round(3) : 0
      after_real = 0 < after_valuation ? (after_valuation.to_f / sum_valuation.to_f * 100).round(3) : 0

      # Ideal ratios
      before_ideal = before_ratio.exists? ? before_ratio.first.value : 0
      after_ideal = after_ratio.exists? ? after_ratio.first.value : 0

      funds = Fund.where(user_id: current_user.id).order('account desc, name desc')
      real = Hash.new
      ideal = Hash.new
      Category.all.each do |category|
        ratio = Ratio.where(user_id: current_user.id, category: category.name)
        valuation = funds.where(category: category.name).sum(:valuation) + \
                    (ratio.present? ? (ratio.first.increase.nil? ? 0 : ratio.first.increase) : 0)
        
        real[category.name] = 0 < valuation ? (valuation.to_f / sum_valuation.to_f * 100).round(3) : 0
        ideal[category.name] = ratio.exists? ? ratio.first.value : 0.0
      end

      return {
        event: event,
        before: {
          category: before_category,
          purchase: before_purchase.to_s(:delimited),
          valuation: before_valuation.to_s(:delimited),
          real: before_real,
          difference: (before_real - before_ideal).round(3)
        },
        after: {
          category: after_category,
          purchase: after_purchase.to_s(:delimited),
          valuation: after_valuation.to_s(:delimited),
          real: after_real,
          difference: (after_real - after_ideal).round(3)
        },
        ratio: {
          real: real,
          ideal: ideal
        }
      }
    end
end
