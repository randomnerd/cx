class UserSerializer < ActiveModel::Serializer
  cached
  delegate :cache_key, to: :object
  attributes :id, :email, :nickname, :created_at, :confirmed_at

  def email
    object.email.empty? ? object.unconfirmed_email : object.email
  end

end
