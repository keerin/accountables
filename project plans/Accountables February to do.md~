# V0.2 to do list

A large part of this release will be adding new features. I also need to fix a number of bugs with the previous release.

## V0.1 bugs

01. When registering sucessfully, you should also be automatically logged in
02. @message does not show when you complete a task for the day, only upon page reload.

## V0.2 features

While V0.1 looked at the MUST items, which were the very basic functions needed for the app to be useable, V0.2 will start to add the functionality that makes the app appealing.

There are two main additions to the app in V0.2 - full user management and adding partners.

### 20/02/16 - Full user management

**settings.haml**

* Create settings.haml
* Add first name, email and password change forms
* Add a delete your account option, including confirm delete option
* Only allow access to the settings page if logged in

**app.rb**

* Create GET and POST routes for settings.haml

### 27/02/16 - Partners

**myaccount.haml / myaccountnope.haml**

* Your accountability partner (Keeping you accountable right now is #{partnerName}. || Invite a partner?)
* Your partner's streak (#{partnerName} has been doing #{habit} for #{days} days.)
* Link to settings page

**model.rb**

* Add hasPartner column (true/false)
* Add partner column (link by ID?)

**app.rb**

* Create add partner functionality and conditional logic (only show if hasPartner in db is false)
* Allow adding partner by email address
* Show partner request message on other person's account page
* Create show partner message and conditional logic (only show if hasPartner in db is true)

### Next time...

The next release will look at adding automated testing and tidying up the whole codebase to ensure best practice for a Ruby app in production.

The final release before V1.0 will be to add something resembling a design, and also the final features. These include:

* indicating the user's best streak
* their partner's best streak
* halting process if the user has not updated in the last day, tied with the user's timezone
* allowing the user to update their profile to include their timezone.
* auto-emailing upon registration, upon partner request, to partner when you complete task for the day
