class KeyWordSet < ActiveRecord::Base
  attr_accessible :keyword

  validates :keyword, presence: true, length: { maximum: 50 }, uniqueness: { case_sensitive: false }
end
