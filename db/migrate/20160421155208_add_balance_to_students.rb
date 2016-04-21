class AddBalanceToStudents < ActiveRecord::Migration
  def change
    add_column :students, :balance, :integer, default: 0
  end
end
