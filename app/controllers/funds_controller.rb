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
    # Import
    funds = []
    CSV.foreach(params[:file].path, headers: true, encoding: 'Shift_JIS:UTF-8') do |row|
      funds << Fund.new(name: row['ファンド名'],
                            category: nil,
                            account: row['口座種別'],
                            purchase: row['買付金額'],
                            valuation: row['評価金額'],
                            user_id: params[:user_id])
    end
    funds.each do |row|
      if Fund.where(user_id: params[:user_id])
             .where(name: row.name)
             .where(account: row.account)
             .where.not(category: nil).count > 0
        row.category = Fund.where(user_id: params[:user_id])
                           .where(name: row.name)
                           .where(account: row.account)
                           .where.not(category: nil)[0].category
      end
    end
    Fund.where(user_id: params[:user_id]).destroy_all
    Fund.import(funds)

    # Return
    @funds = Fund.where(user_id: params[:user_id]).order('account DESC')
    redirect_to user_funds_path
  end

  def set_category
    fund = Fund.find(params[:id])
    fund.update(category: (params[:category] == '' ? nil : params[:category]))
    render json: { status: 'success' }
  end

  private
    def is_exists(funds_org, funds_new)
      org.foreach do |row|
        if row.name == funds_new['ファンド名'] && row.account == funds_new['口座種別']
          return true
        end
      end
      return false
    end

end
