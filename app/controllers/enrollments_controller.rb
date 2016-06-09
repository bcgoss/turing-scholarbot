class EnrollmentsController < ApplicationController
  def new
    @student = Student.find(params[:student_id])
    @enrollment = @student.enrollments.new
  end

  def create
    @student = Student.find(params[:student_id])
    @enrollment = EnrollmentsManager.new(params[:enrollment][:course_ids], @student)

    if @enrollment.create
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
