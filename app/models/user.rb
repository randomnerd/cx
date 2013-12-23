class User < ActiveRecord::Base
  validates_presence_of :email
  # validates_uniqueness_of :nickname
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :async

  has_many :blocks
  has_many :orders
  has_many :wallets
  has_many :workers
  has_many :balances
  has_many :deposits
  has_many :messages
  has_many :withdrawals
  has_many :block_payouts
  has_many :notifications
  has_many :address_book_items
  has_many :worker_stats, through: :workers
  has_many :balance_changes, through: :balances
  after_create :set_initial_values

  scope :filter_query, -> q { where('id = ? or nickname like ? or email like ?', q.to_i, "%#{q}%", "%#{q}%") }

  def set_initial_values
    self.skip_reconfirmation!
    set_nickname
    set_totp_key
  end

  def set_nickname(name = nil)
    return if !name && self.nickname && !self.nickname.try(:empty?)
    name ||= email.split('@').first
    return if name == nickname
    name += rand(10).to_s while !!User.find_by_nickname(name)
    update_attribute :nickname, name
  end

  def set_totp_key
    return if self.totp_key && !self.totp_key.try(:empty?)
    update_attribute :totp_key, ROTP::Base32.random_base32
  end

  def totp
    return unless self.totp_key
    @totp ||= ROTP::TOTP.new(self.totp_key)
  end

  def totp_qrcode_url
    return unless totp
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
    email == 'erundook@gmail.com' || email == 'captain@captainfuture-productions.com'
  end

  def banned?
    return false unless banned_until.present?
    banned_until > Time.now.utc
  end
end
