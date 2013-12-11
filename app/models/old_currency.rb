class OldCurrency
  include Mongoid::Document
  store_in collection: "currencies"

  field :name, type: String
  field :desc, type: String
  field :host, type: String
  field :port, type: Integer
  field :user, type: String
  field :pass, type: String
  field :public, type: Boolean
  field :miningEnabled, type: Boolean
  field :miningPublic, type: Boolean
  field :miningFee, type: Float
  field :miningUrl, type: String
  field :txConfirms, type: Integer
  field :blockConfirms, type: Integer
  field :txFee, type: Float
  field :algo, type: String

  def self.migrate
    OldCurrency.all.each do |curr|
      Currency.create({
        name: curr.name,
        desc: curr.desc,
        tx_conf: curr.txConfirms,
        tx_fee: curr.txFee,
        blk_conf: curr.blockConfirms,
        algo: curr.algo,
        mining_enabled: curr.miningEnabled,
        mining_public: curr.miningPublic,
        mining_fee: curr.miningFee,
        mining_url: curr.miningUrl,
        public: curr.public,
        user: curr.user,
        pass: curr.pass,
        # host: curr.host,
        port: curr.port,
        old_id: curr._id
      })
    end
  end

  def self.full_migrate
    OldCurrency.migrate
    OldTradePair.migrate
    OldChartItem.migrate
    OldUser.migrate
  end
end
