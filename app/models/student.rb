class Student < ActiveRecord::Base
  has_many :enrollments
  has_many :courses, through: :enrollments

  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }

  before_validation :set_registration_code

  def set_registration_code
    self.registration_code = rand.to_s[2..8]
  end

  def depesit!(amount)
    update_attributes(balance: balance + amount)
  end

  def withdraw!(amount)
    update_attributes(balance: balance - amount)
  end
end
