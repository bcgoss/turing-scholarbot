class EnrollmentsController < ApplicationController
  def new
    @student = Student.find(params[:student_id])
    @enrollment = @student.enrollments.new
  end

  def create
    @student = Student.find(params[:student_id])
    params[:enrollment][:course_ids].each do |course_id|
      @student.enrollments.new(course_id: course_id, score: 100)
    end
    if @student.save
      @student.courses.each do |course|
        course.update_attributes(active: true)
      end
      EnrollmentMailer.deliver_confirmation_email_for(@student) # **** THIS IS NOT REAL! ****
      redirect_to student_path(@student)
    else
      flash[:errors] = "Something went wrong. Try again."
      render :new
    end
  end
end

# Interested in how you'd create a real mailer? 
# Check out http://guides.rubyonrails.org/action_mailer_basics.html
# (but finish your work first :) ) 
