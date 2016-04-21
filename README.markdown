# Callbacks & Scopes

## Goals

* define callbacks; explain good and bad use cases
* implement callbacks in a Rails app
* refactor a controller to use callbacks where appropriate and a PORO when not
* implement filter functionality using both class methods and scopes

## What is a Callback?

### IRL

When someone is told to go brush their teeth, there are many things that happen (_callbacks_)besides the actual tooth-brushing (**EVENT**):

* _go to sink_
* _grab toothbrush_
* _open toothpaste tube_
* _put toothpaste on toothbrush_
* _close toothpaste tube_
* **BRUSH TEETH**
* _turn on faucet_
* _spit_
* _rinse toothbrush_
* _turn off faucet_
* _put toothbrush back in cup_

In pairs, share one example of a real-life situation where there would be callbacks triggered either _before_ or _after_ the main event. 

### In Rails

Callbacks are actions that can happen before, during, or after an ActiveRecord object's lifecycle methods (validate, save, create, destroy, etc.) In Rails, the **EVENT** is the process of writing something to the database. 

One example of this might be generating a random registration code (_callback_) when a new student is saved into a school database (**EVENT**). 

In pairs, share an example of a web application situation where callbacks might be used. 

## Try It

Open `test/models/student_test.rb` and figure out what should happen when a student is saved. Run the test `(rake test test/models/student_test.rb`), then make it pass. 

## An Example

Take a look at this controller. With a pair, pick out at least three things that are not "controller business". 

```ruby
class OrdersController < ApplicationController
  def create
    credit_card = order_params[:credit_card_number]
    credit_card = credit_card.gsub(/-|\s/,'')
    order_params[:credit_card_number] = credit_card

    @order = Order.new(order_params)

    if @order.save
      flash[:notice] = "Order was created."
      OrderMailer.order_confirmation(@order.user).deliver
      @order.user.update_attributes(status: "active")
      redirect_to current_user
    else
      render :new
    end
  end
end
```

Can we use callbacks to fix this controller? Let's see: 

```ruby
class Order < ActiveRecord::Base
  before_validation :sanitize_credit_card
  after_create :send_order_confirmation
  after_save :set_user_to_active
  
  private

  def sanitize_credit_card
    credit_card.gsub(/-|\s/,'')
  end

  def send_order_confirmation
    OrderMailer.order_confirmation(user).deliver 
  end

  def set_user_to_active
    user.update_attributes(status: "active")
  end
end
```

This is definitely different, but is it really better? Let's talk about some principles one should follow when using callbacks. 

## "Rules" of Callbacks

There are 19 total callback methods. Here are some of them, listed in the order they run:

* before_validation
* after_validation
* before_save
* before_create (for new records)
* before_update (for existing records)
* **[WRITE TO DATABASE]**
* after_create (for new records)
* after_update (for existing records)
* after_save
* before_destroy
* after_destroy
* dependent: :destroy is also a callback of sorts

Here are some rules of thumb for using callbacks:

* Callbacks should not affect any other object's state. This not only follows the Single Responsibility Principle, but it also avoids problems in testing. 
* Callbacks that happen **after** something tend to be the most problematic since they usually trigger an action on another object. 
* As yourself: "Does this callback affect *only* the internal state of this specific object?" If so, then it's probably ok to use the callback. If not, you may want to use a PORO in order to handle a process involving multiple objects. 
* Make callback methods `private` so that they cannot be called outside of the class. 
* *Warning*: Some methods do not trigger callbacks. Read more [here](http://edgeguides.rubyonrails.org/active_record_callbacks.html#skipping-callbacks). 

With a pair:

* Use the rules above to determine what should and should not stay in the Order class from the above example. 
* Brainstorm where in your own Little Shop might you use a callback that follows the rules above.

## A Better Approach

Let's go back to the Order problem from above. 

When multiple objects need to be created/accessed/modified for one "event" to take place, the best approach is to use a PORO: Plain Old Ruby Object. In our example, we might choose to use a OrderCompletion object in the `create` action, like so:

```ruby
class OrdersController < ApplicationController
  def create
    @order = Order.new(order_params)
    @order_completion = OrderCompletion.new(@order)

    if @order_completion.create
      flash[:notice] = "Order was created."
      redirect_to current_user
    else
      render :new
    end
  end
end
```

What does this OrderCompletion object do? 

```ruby
class OrderCompletion
  attr_accessor :order
  
  def initialize(order)
    @order = order
  end
  
  def create
    if order.save
      send_order_confirmation
      set_user_to_active
    end
  end

  def send_order_confirmation
    OrderMailer.order_confirmation(user).deliver 
  end

  def set_user_to_active
    order.user.update_attributes(status: "active")
  end
end
```

## Try It

Open `test/integration/user_enrolls_student_in_course_test.rb` and figure out what should happen when a student is saved. Run the test `(rake test test/integration/user_enrolls_student_in_course_test.rb`). It should already be passing, but the controller is a basket case! Determine what things could become legit callbacks using the rules above, and which should be moved into a PORO. (The PORO is not created -- you'll need to do that). 

Where might this pattern be useful in Little Shop? 

## Mostly Unrelated: Revisiting Scopes

Before we talk about scopes, make the two tests in `test/models/course_test.rb` pass using *class methods*. 

### WTF are scopes? 

Scopes allow you define and chain query criteria in a declarative and reusable manner. They take lambdas, which you can think of as methods that doesn't have a name definition.

```ruby
class Order < ActiveRecord::Base
  scope :complete, -> { where(complete: true) }
  scope :today, -> { where("created_at >= ?", Time.zone.now.beginning_of_day) }
  scope :newer_than, ->(date) {  where("start_date > ?", date) }
end
```

### If time permits: Transactions

* What is a transaction?
* When should a transaction take place?
* What is the syntax of a transaction? 

Check out the test `/test/integration/user_adjusts_bank_balance_test.rb`

## Try It

Modify your implementation to use scopes instead of class methods. Make sure your tests still pass. 

## Further Resources

* [Active Record Callbacks Documentation](http://guides.rubyonrails.org/active_record_callbacks.html)
* [The Problem with Rails Callbacks](http://samuelmullen.com/2013/05/the-problem-with-rails-callbacks/)
* What's the difference between scopes and class methods then? [Check out this blog post](http://blog.plataformatec.com.br/2013/02/active-record-scopes-vs-class-methods/). 