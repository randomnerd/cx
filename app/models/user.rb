class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_many :messages
  has_many :orders
  has_many :balances
  after_create :set_nickname

  def set_nickname(name = nil)
    name ||= email.split('@').first
    return if name == nickname
    name += rand(10).to_s while !!User.find_by_nickname(name)
    update_attribute :nickname, name
  end

  def balance_for(cid)
    balances.find_by_currency_id(cid)
  end
end
