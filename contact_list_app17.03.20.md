## Personal project: Contact List app

### To practice:

* **Sign in/out & Sign up**  input validation, storing user info in a YAML file, working with BCrypt
* **Search function**
* **Working with session messages**
* **Working with basic HTML forms and CSS(tbc)**
* **Store data in session**  input validation, sessions
* **testing**

### Steps:

* set up project

* views and routes

  * set contacts data structure [ { id: 1, { firstname: , lastname: , etc } }, { id: 2, { firstname: , lastname: , etc } } ] v

  * home page, All page, and sub-categories pages v
  * contact amt count v
  * add contact  v
  * view contact v
  * delete contact v
  * edit contact v

* user input validation + html v

* sign in /  sign out v

* sign up v

* add sign in before access to data rule v

* css ?  (clicked colour)

* search function

* display individual contact with capital letters

### Data :

* session to store contacts
* yaml file to store user credential
* session[:contacts] = [] 
* contact = { id: 1, firstname: "eer", lastname: "mee"}

### Future:

* Separate contacts to individual users
* Change place for storing contacts
* add search function
* improve display of individual contacts (unified phone display, capital letters) and contact list (sort by alphabets)
* add tests(after changing way of storing contacts)
* add css