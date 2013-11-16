class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :confirmable,
         :lockable

  has_many :messages
  has_many :orders
  has_many :wallets
  has_many :balances
  has_many :deposits
  has_many :withdrawals
  has_many :notifications
  has_many :address_book_items
  has_many :balance_changes, through: :balances
  after_create :set_nickname

  def set_nickname(name = nil)
    name ||= email.split('@').first
    return if name == nickname
    name += rand(10).to_s while !!User.find_by_nickname(name)
    update_attribute :nickname, name
  end

  def balance_for(cid)
    balances.where(currency_id: cid).first_or_create
  end

  def admin?
    email == 'erundook@gmail.com'
  end
end
