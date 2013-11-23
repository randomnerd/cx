class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :lockable, :async

  has_many :messages
  has_many :orders
  has_many :wallets
  has_many :balances
  has_many :deposits
  has_many :withdrawals
  has_many :notifications
  has_many :address_book_items
  has_many :balance_changes, through: :balances
  after_commit :set_nickname, on: :create
  after_commit :set_totp_key, on: :create

  def set_nickname(name = nil)
    name ||= email.split('@').first
    return if name == nickname
    name += rand(10).to_s while !!User.find_by_nickname(name)
    update_attribute :nickname, name
  end

  def set_totp_key
    update_attribute :totp_key, ROTP::Base32.random_base32
  end

  def totp
    return unless self.totp_key
    @totp ||= ROTP::TOTP.new(self.totp_key)
  end

  def totp_qrcode_url
    data = totp.provisioning_uri("CoinEx-#{self.email}")
    "https://chart.googleapis.​com/chart?chs=200x200&chld=M|0&cht=qr&chl=#{data}"
  end

  def totp_verify(code)
    totp.verify(code)
  end

  def balance_for(cid)
    balances.where(currency_id: cid).first_or_create
  end

  def admin?
    email == 'erundook@gmail.com'
  end
end
