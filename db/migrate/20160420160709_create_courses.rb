class CreateCourses < ActiveRecord::Migration
  def change
    create_table :courses do |t|
      t.string :subject

      t.timestamps null: false
    end
  end
end
