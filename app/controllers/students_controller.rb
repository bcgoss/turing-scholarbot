class StudentsController < ApplicationController
  def show
    @student = Student.find(params[:id])
  end

  def index
    @students = Student.all
  end

  def bank
    @students = Student.all
  end

  def transfer
    @transfer_from = Student.find(params[:transfer_from][:student_id])
    @transfer_to   = Student.find(params[:transfer_to][:student_id])

    @transfer_from.withdraw!(params[:amount].to_i)
    @transfer_to.deposit!(params[:amount].to_i)
    
    redirect_to students_path
  end
end