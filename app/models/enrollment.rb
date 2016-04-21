class Enrollment < ActiveRecord::Base
  belongs_to :student
  belongs_to :course
  
  delegate  :subject, to: :course
end
