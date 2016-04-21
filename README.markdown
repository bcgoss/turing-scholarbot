# Callbacks, Transactions, & Scopes

## What is a Callback?

Callbacks are actions that can happen around an ActiveRecord object's lifecycle: create, update, and delete. These actions can happen before, after, or around ActiveRecord methods. 

## Callback Rules

* Callbacks should not affect any other object's state. This not only follows the Single Responsibility Principle, but it also avoids problems in testing. 
* Callbacks that happen *after* something tend to be the most problematic since they usually trigger an action on another object. 
* As yourself: "Does this callback affect *only* the internal state of this object?" If so, then it's probably ok to use the callback. If not, you may want to use a PORO in order to handle a process involving multiple objects. 
* Always protect or private callback methods


* 19 total callback methods

• before_validation • after_validation • before_save
• around_save
• before_create (for new records) and before_update (for existing records) • around_create (for new records) and around_update (for existing records) • after_create (for new records) and after_update (for existing records)
• after_save
* before_destroy
• around_destroy executes a DELETE database statement on yield
• after_destroy is called after record has been removed from the database and all attributes have been
frozen (read-only)

* dependent: :destroy

* returning false halts the execution chain (ie - no further callbacks are run)


## No callbacks:

• decrement
• decrement_counter • delete
• delete_all
• increment
• increment_counter • toggle
• touch
• update_column
• update_columns
• update_all
• update_counters


## Further Resources

* [Active Record Callbacks Documentation](http://guides.rubyonrails.org/active_record_callbacks.html)
* [The Problem with Rails Callbacks](http://samuelmullen.com/2013/05/the-problem-with-rails-callbacks/)
* 