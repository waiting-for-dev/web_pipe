# Plugging operations

Operations are plugged to your application through the use of the DSL method
`plug`. The first argument it always takes is a symbol with the name you want
to give to the operation (needed to allow injection on initialization).

Remember, an operation is nothing more than a function (in ruby anything
responding to `#call`) which takes a struct with all the connection information
and which must return another instance of it. The first operation in the stack
receives a struct which has been automatically created with all the request
information. Then, any operation can add to it the needed information to create
a response.
