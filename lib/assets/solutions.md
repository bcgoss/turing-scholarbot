## Solutions

#### `student_test.rb`
In `student.rb`, 

```ruby
  before_create :set_registration_code

  private
	  def set_registration_code
	    o = [('a'..'z'), ('A'..'Z'), (0..9)].map { |i| i.to_a }.flatten
	    string = (0...7).map { o[rand(o.length)] }.join

	    self.registration_code = string
	  end
```

#### Things that are not "controller business"

* Removing dashes (or sanitizing) the credit card number
* Sending the order confirmation e-mail on successful save
* Updating the order user's status to active

#### Rules of Callbacks

Give example from little_shop to suggest as service object candidate.

Like a service call to PayPal/Stripe, but probably not a phone/text message order confirmation.

#### We Do

Implement a design similar to the refactored PORO from the earlier example.

#### Ask what else you can do to demonstrate Transactions.

```ruby
def transfer
    amount = params[:amount].to_i

    @transfer_from = Student.find(params[:transfer_from][:student_id])
    @transfer_to   = Student.find(params[:transfer_to][:student_id])

    ActiveRecord::Base.transaction do
      @transfer_from.withdraw!(amount)
      raise ActiveRecord::Rollback if @transfer_from.balance < 0
      @transfer_to.deposit!(amount)
    end
    
    redirect_to students_path
  end
```