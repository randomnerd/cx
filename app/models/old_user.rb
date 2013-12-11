class OldUser
  include Mongoid::Document
  store_in collection: "users"

  field :emails, type: Array
  field :profile, type: Hash
  field :createdAt, type: Integer

  def self.migrate
    OldUser.all.each do |user|
      new_user = User.create({
        email: user.emails.first['address'],
        nickname: user.profile.try(:[], 'nickname'),
        password: SecureRandom.hex(32),
        created_at: Time.at(user.createdAt/1000),
        confirmed_at: Time.now.utc,
        totp_key: user.profile.try(:[], 'totp').try(:[], 'base32'),
        totp_active: user.profile.try(:[], 'totp').try(:[], 'active')
      })
      OldBalance.where(userId: user._id).all.each do |b|
        next unless (b.balance > 0 || b.held > 0)
        cid = Currency.find_by_old_id(b.currId)
        new_user.balance_for(cid).add_funds(b.balance + b.held, nil, 'migrated balance')
      end
    end
  end
end
