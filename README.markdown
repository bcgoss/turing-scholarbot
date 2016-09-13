---
title: 'Callbacks & Scopes'
length: 90 mins
tags: ruby, callbacks, scopes
--- 

## Goals

* Define callbacks; explain good and bad use cases
* Implement callbacks in a Rails app
* Refactor a controller to use callbacks where appropriate and a PORO when not
* Implement filter functionality using both class methods and scopes

## Review

* What is CRUD?
* What methods does Rails have for CRUD operations?

## What is a Callback?

* A callback is a hook into an ActiveRecord object's life cycle.
* Actions can be performed before, after, or around events like create, validate, or save.

### There are [25 total callback methods](http://guides.rubyonrails.org/active_record_callbacks.html).

Here are some of them, listed in the order they run:

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

### In Real Life

When someone is told to go brush their teeth, there are many things that happen (i.e., _callbacks_) besides the actual tooth brushing (i.e., **the main event**):

* _go to sink_
* _grab toothbrush_
* _open toothpaste tube_
* _put toothpaste on toothbrush_
* _close toothpaste tube_
* **brush teeth**
* _turn on faucet_
* _spit_
* _rinse toothbrush_
* _turn off faucet_
* _put toothbrush back in cup_

### As a Class

What is an example of a real-life situation where there would be callbacks triggered either _before_ or _after_ the main event?

### In Rails

Callbacks are actions that can happen before, during, or after an ActiveRecord object's lifecycle methods (validate, save, create, destroy, etc.) In Rails, we define the **EVENT** as the process of _writing something to the database_.

One example of this might be generating a random registration code (_callback_) when a new student is saved into a school database (**EVENT**). 

### As a Class

What is an example of a web application situation where callbacks might be used?

### In Pairs

Open `test/models/student_test.rb` and figure out what should happen when a student is saved. Run the test using `rake test test/models/student_test.rb` and then make it pass. 

## An Example - Controller Business

Take a look at this controller. With your pair, pick out at least three things that are not controller business logic.

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

Can we use callbacks to fix this controller? How? Let's see.

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

The above sample is definitely different, but is it really better? Let's talk about some principles one should follow when using callbacks. 

## Rules of Thumb for Using Callbacks

* Make callback methods `private` so that they cannot be called outside of the class. 
* It's difficult to use callbacks if you're testing - requires stubbing the callback methods, data returned by callbacks, or other logic for the test to pass.
* Single Responsibility Principle - a class should only have one reason to change (i.e., one purpose for a type of user)
  * Callbacks should not affect any other object's state. This not only follows the SRP, but it also avoids problems in testing. 
* `before_` callbacks are used to prepare an object to be saved (e.g., update timestamp, incrementing object's counter), whereas `after_` callbacks are related to saving or persisting the object. Once an object has been committed, its purpose has been fulfilled.
  * Callbacks that happen **after** something tend to be the most problematic since they usually trigger an action on another object.
  * Ask yourself: "Does this callback affect *only* the internal state of this specific object?" If so, then it's probably ok to use the callback. If not, you may want to use a PORO in order to handle the business logic dictating a process involving multiple objects.
  * A service object is model logic that reaches across multiple models, the action is complex and/or the action interacts with an external service, like API calls.
* *Warning*: Some methods do not trigger callbacks. Read more [here](http://edgeguides.rubyonrails.org/active_record_callbacks.html#skipping-callbacks).

### In Pairs

* Use the rules above to determine what should and should not stay in the Order class from the above example.

## A Better Approach

Let's go back to the Order problem from above. 

When multiple objects need to be created/accessed/modified for one "event" to take place, the best approach is to use a PORO: a Plain Old Ruby Object. In our example, we might choose to use a OrderCompletion object in the `create` action, like so:

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

What does this `OrderCompletion` object do?

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

## We Do

View the code. What should happen when a student is saved in `test/integration/user_enrolls_student_in_course_test.rb`?

Run the test using `rake test test/integration/user_enrolls_student_in_course_test.rb`

It should already be passing, but the controller is ridiculous! Determine what things could become legit callbacks using the rules above, and which should be moved into a PORO, which you will need to create.

Where might this pattern be useful in Little Shop?

Before we talk about scopes, make the two tests in `test/models/course_test.rb` pass using *class methods*. 

## What are Scopes?

What is an alias?

Scopes allow you define and chain query criteria in a declarative and reusable manner. They take lambdas, which you can think of as methods that don't have a name definition.

```ruby
class Order < ActiveRecord::Base
  scope :complete, -> { where(complete: true) }
  scope :today, -> { where("created_at >= ?", Time.zone.now.beginning_of_day) }
  scope :newer_than, -> (date){  where("start_date > ?", date) }
end
```

## But what's the difference between scopes and class methods?

* Use scopes when the logic is small and class methods when it is complex.
* Scopes must return an `ActiveRecord::Relation` object - classes can return anything.
* Scopes are chainable.

## If time permits: Transactions

### What is a transaction?

A transaction is comprised of four ACID properties:

* Atomic - transactions act as a single unit (like atoms!) with the option from the database to be committed or aborted
* Consistency – database retains state after syntactically/logically sound transactions occur (programmer enforced)
* Isolation – one transaction does not affect the outcome of another transaction (like an ATM)
* Durability – if it’s committed, it stays committed to non-volatile memory – crashes don’t affect information loss

#### When should a transaction take place?

When you need to ensure that all database transactions occur atomically.

#### What is the syntax of a transaction?

The canonical ATM example:

```ruby
ActiveRecord::Base.transaction do
  david.withdrawal(100)
  mary.deposit(100)
end
```

You can mix different model types in a transaction block, since the transaction is bound to the database connection and not the specific type:

```ruby
Client.transaction do
  @client.user.login
  Product.first.destroy!
end
```

The following syntax is also valid:

```ruby
@client.transaction do
  @client.user.login
  Product.first.destroy!
end
```

You do not need to wrap single database/ActiveRecord queries in a transaction block, since each query is automatically wrapped in a `save!` and `destroy!` method.

#### What if a transaction is invalid?

We reset the state of records through a process called rollback, which in Rails are triggered via an exception.

```ruby
ActiveRecord::Base.transaction do
  david = User.find_by_name("david")
  raise ActiveRecord::RecordNotFound if david.nil?
end
```

```ActiveRecord::Rollback``` is another way to invalidate a transaction and reset database records without raising an error.

Check out the test `test/integration/user_adjusts_bank_balance_test.rb`

## Try It

Modify your implementation to use scopes instead of class methods. Make sure your tests still pass. 

## Further Resources

* [Active Record Callbacks Documentation](http://guides.rubyonrails.org/active_record_callbacks.html)
* [The Problem with Rails Callbacks](http://samuelmullen.com/2013/05/the-problem-with-rails-callbacks/)
* What's the difference between scopes and class methods then? [Check out this blog post](http://blog.plataformatec.com.br/2013/02/active-record-scopes-vs-class-methods/).
* [Transactions in Rails](http://markdaggett.com/blog/2011/12/01/transactions-in-rails/)