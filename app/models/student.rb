class Student < ActiveRecord::Base
  has_many :enrollments
  has_many :courses, through: :enrollments

  validates :balance, :numericality => { :greater_than_or_equal_to => 0 }

  def deposit!(amount)
    update_attributes(balance: balance + amount)
  end

  def withdraw!(amount)
    update_attributes(balance: balance - amount)
  end
end
