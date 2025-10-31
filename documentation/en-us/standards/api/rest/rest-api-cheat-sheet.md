# REST API Cheat Sheet

## Preface

This document describes standard for RETS API return HTTP status codes.

### Synchronous method calls

These responses must be produced by synchronous endpoint calls according to result of the underlying methods.

#### GET HTTP method

The GET HTTP method requests a representation of the specified resource. Requests using GET should only be 
used to request data and shouldn't contain a body.

|Purpose|Response|Reason|Recommended client action|
|-------|--------|------|-------------------------|
|Get resource from server|200 Ok|Returned when request succeeds and resource is found|Show returned resource|
|Get resource from server|404 Ok|Returned when request resource is not found|Show infromation about missing resourrce|

#### POST HTTP method

The POST HTTP method sends data to the server. The type of the body of the request is indicated by the 
Content-Type header.

The difference between PUT and POST is that PUT is idempotent: calling it once is no different from 
calling it several times successively (there are no side effects). Successive identical POST requests 
may have additional effects, such as creating the same order several times.

|Purpose|Response|Reason|Recommended client action|
|-------|--------|------|-------------------------|
|When resource needs to be created|201 Created|Returned when a new resource was successfully created|Show success message, show new resource|
|When resource needs to be created|204 No Content|Returned when resource was successfully created and there is no content to return|Show success message|
|When resources needs to be obtained by query|200 OK|Query succeeded and resources returned|Display returned resources|
|When resources needs to be obtained by query|206 Partial Content 1)|Returned when resource was successfully read and additional call(s) are required to obtain all data|Proceed with additional calls|
|When resources needs to be obtained by query|404 Not found 1)|Returned when resource was successfully read and additional call(s) are required to obtain all data|Displaz infromation that no resources fits to the query|

1\) use only for GOV project

#### PUT HTTP method

The PUT HTTP method creates a new resource or replaces a representation of the target resource with 
the request content.

|Purpose|Response|Reason|Recommended client action|
|-------|--------|------|-------------------------|
|Replace resource on the server|200 Ok|The resource was replaced successfuly|Display success message and returned resource|
|Replace resource on the server|204 No Content|The resource was replaced successfuly and there is no content to return|Display success message|
|Replace resource on the server|404 Not Found|The resource does not exist|Display infromation that resource was not found|

#### PATCH HTTP method

The PATCH HTTP method applies partial modifications to a resource.

PATCH is somewhat analogous to the "update" concept found in CRUD (in general, HTTP is different 
than CRUD, and the two should not be confused).

In comparison with PUT, a PATCH serves as a set of instructions for modifying a resource, whereas 
PUT represents a complete replacement of the resource. A PUT request is always idempotent 
(repeating the same request multiple times results in the resource remaining in the same 
state), whereas a PATCH request may not always be idempotent. For instance, if a resource includes 
an auto-incrementing counter, a PUT request will overwrite the counter (since it replaces 
the entire resource), but a PATCH request may not.

|Purpose|Response|Reason|Recommended client action|
|-------|--------|------|-------------------------|
|Update resource on the server|200 Ok|The resource was updated successfuly|Show updated resource|
|Update resource on the server|204 No content|The resource is updated successfuly and there is no content to return|Show success message|
|Update resource on the server|404 Not Found|The resource does not exist|Show information that resource doesn't exist.|

#### DELETE HTTP method

The DELETE HTTP method asks the server to delete a specified resource.

The DELETE method has no defined semantics for the message body, so this should be empty.

|Purpose|Response|Reason|Recommended client action|
|-------|--------|------|-------------------------|
|Delete resource form server|204 No content|The resource was updated successfuly|Show success message|
|Delete resource form server|404 Not Found|The resource does not exist|Show infromation that resource doesn't exist|

### Synchronous method calls

These responses must be produced by standard endpoint calls according to result of the underlying methods.

#### POST HTTP method

|Purpose|Response|Reason|Recommended client action|
|-------|--------|------|-------------------------|
|Post data to asynchronous processing|202 Accepted|Request was acepted for further processing|Show info about asynchronous porcessing (job id)|

1\) method is not implemented in .NET 9, use post instead

2\) use only for GOV project

### Security responses

These responses must be returned as result of security related issues. These responses are created and returned before controller is reached and any controller action is taken.

|Response|Reason|Recommended client action|
|--------|------|-------------------------|
|401 Unauthorized|User is not authenticated , there is no session created for this user or token is invalid.|Redirect to login page.|
|403 Forbidden|User is not authorized for current operation. This can be forbidden either by ABAC or RBAC.|Correct response on client side is to show unathorized error message to user.|

### Server error responses

These responses must be returned as result of system failures during request processing. Failure can be caused by internal errors or by missing connected resource or service.

|Response|Reason|Recommended client action|
|--------|------|-------------------------|
|400 Bad Request|Request data are malformed or invalid.|Client must fix request data and call service again.|
|500 Internal server error|An unexpected error has occurred during processing of the request. Error is not recoverable.|Do not repeat the request and log the error. Code must be fixed.|
|503 Service unavailable|Connected resources or services are not available.|Repeat request after some time.|
