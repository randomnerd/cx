class UserSerializer < ActiveModel::Serializer
  attributes :id, :email, :nickname, :created_at, :confirmed_at, :admin,
             :totp_qr, :totp_active, :updated_at, :confirm_orders, :no_fees,
             :api_key

  def email
    object.email.empty? ? object.unconfirmed_email : object.email
  end

  def admin
    object.admin?
  end

  def totp_qr
    return if object.totp_active
    object.totp_qrcode_url
  end
end
