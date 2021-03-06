class Api::V2::CurrenciesController < Api::V2::BaseController
  has_scope :by_name, as: :name

  def collection
    @collection ||= end_of_association_chain.public
  end

  def generate_address
    return unless current_user
    current_user.wallets.create(currency_id: resource.id)
    balance = current_user.balance_for(resource.id)
    render json: {
      balances: [
        BalanceSerializer.new(balance)
      ]
    }
  end

  def withdraw
    head(:unauthorized) and return unless current_user
    if current_user.balances.where('amount < 0').count > 0
      current_user.notifications.create(
        title: "#{resource.name} withdrawal failed",
        body: "Please fix (deposit/buy) your negative balances first."
      )
      head(:unauthorized) and return
    end

    if current_user.totp_active
      unless current_user.totp_verify(params[:totp])
        render json: {errors: {totp: 'Wrong TOTP'}}, status: 401
        return
      end
    end

    w = current_user.withdrawals.create(
      currency_id: resource.id,
      amount:  params[:amount].to_f * 10 ** 8,
      address: params[:address]
    )
    if w.persisted?
      notify = current_user.notifications.create(
        title: "#{resource.name} withdrawal queued",
        body: "Withdraw #{params[:amount]} #{resource.name} to #{params[:address]}"
      )
    else
      errors = w.errors.messages.map {|field, msg| [field,msg].join(' ')}.join(', ')
      notify = current_user.notifications.create(
        title: "#{resource.name} withdrawal failed",
        body: "Errors: #{errors}"
      )
    end
    render json: notify
  end
end
