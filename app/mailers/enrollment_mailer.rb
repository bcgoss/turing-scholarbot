class EnrollmentMailer
  def self.deliver_confirmation_email_for(student)
    puts "*************************"
    puts "#{student.name} enrolled."
    puts "*************************"
  end
end