class Api::V2::CurrenciesController < Api::V2::BaseController
  has_scope :by_name, as: :name
  def generate_address
    return unless current_user
    current_user.wallets.create(currency_id: resource.id)
    balance = current_user.balance_for(resource.id)
    render json: {
      balances: [
        BalanceSerializer.new(balance, root: false)
      ]
    }
  end

  def withdraw
    head(:unauthorized) and return unless current_user
    unless current_user.totp_active && current_user.totp_verify(params[:totp])
      render json: {errors: {totp: 'Wrong TOTP'}}, status: 401
      return
    end

    current_user.withdrawals.create(
      currency_id: resource.id,
      amount:  params[:amount].to_f * 10 ** 8,
      address: params[:address]
    )
    notify = current_user.notifications.create(
      title: "#{resource.name} withdrawal queued",
      body: "Withdraw #{params[:amount]} #{resource.name} to #{params[:address]}"
    )
    render json: {
      notifications: [
        NotificationSerializer.new(notify, root: false)
      ]
    }
  end
end
