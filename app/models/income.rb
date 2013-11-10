class Income < ActiveRecord::Base
  belongs_to :currency
  belongs_to :subject, polymorphic: true
end
