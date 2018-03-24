[🔙 Channels and Messages][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Introducing Goophr 🔜][upcoming-chapter]

# Chapter 4. The RESTful Web

## HTTP and Sessions

_skimmed_.

### A Simple Web Server

Go provides us with an inbuilt library for building web servers, `net/http`. For every endpoint
we want to create on our server, we need to do two things:

1. Create a handler function for the endpoint, which accepts two params: one for writing to
response and one to handle the incoming Request.
1. Register the endpoint using `net/http.HandleFun`.

Here's a simple web server that accepts all incoming requests, logs them to the console, and
returns a `Hello, World!` message.

```go
// helloServer.go

package main

import (
  "fmt"
  "log"
  "net/http"
)

func helloWorldHandler(w http.ResponseWriter, r *http.Request) {
  msg := fmt.Sprintf("Received request [%s] for path: [%s]", r.Method, r.URL.Path)
  log.Println(msg)

  response := fmt.Sprintf("Hello, World! at Path: %s", r.URL.Path)
  fmt.Fprintf(w, response)
}

func main() {
  http.HandleFunc("/", helloWorldHandler) // Catch all Path

  log.Println("Starting server at port :8080...")
  http.ListenAndServe(":8080", nil)
}
```

Here are some sample requests and responses when requesting the URL in the browser:

```
http://localhost:8080/  --> Hello, World! at Path: / 
http://localhost:8080/asdf  htt--> Hello, World! at Path: /asdf 
http://localhost:8080/some-path/123  --> Hello, World! at Path: /some-path/123 
```

And the following is the server output:

```
2017/10/03 13:35:46 Starting server at port :8080... 
2017/10/03 13:36:01 Received request [GET] for path: [/] 
2017/10/03 13:37:22 Received request [GET] for path: [/asdf] 
2017/10/03 13:37:40 Received request [GET] for path: [/some-path/123]
```

Notice that even though we have provided multiple paths, they are all defaulting to the root `/`
path.

### Designing a REST API

#### The Data Format

##### The Book Resource

Here's the JSON overview of our resource, book:

```json
{
  "id": "string", 
  "title": "string", 
  "link": "string"
}
```

##### `GET /api/books`

This REST API call will retrieve a list of all items of the book resource type, and respond with
a JSON collection. Here's the simple format we'll be returning:

Request: `GET "<URL>/api/books/"`

Response:

```json
[ 
  { 
     "id": "1", 
     "title": "book1", 
     "link": "http://link-to-book-1.com" 
   }, 
   { 
     "id": "2", 
     "title": "book2", 
     "link": "http://link-to-book-2.com" 
   } 
 ]
```

##### `GET /api/books/<id>`

This form of the `GEt` call will retrieve a single book resource based on the `<id>` provided.

Request: `GET "<URL>/api/books/1"`

Response:

```json
{ 
  "id": "1", 
  "title": "book1", 
  "link": "http://link-to-book-1.com" 
}
```

##### `POST /api/books`

Request: `POST "<URL>/api/books"`

Payload:

```json
{ 
  "title": "book5", 
  "link": "http://link-to-book-5.com" 
} 
```

Response:

```json
{ 
  "id": "3", 
  "title": "book5", 
  "link": "http://link-to-book-5.com" 
}
```

##### `PUT /api/books/<id>`

We'll use `PUT` to update  aspecific resource. `PUT` defined in our API is stringent with 
accepting the payload without the complete data, that is, it will reject incomplete payload requests.

Request: `PUT "<URL>/api/books/3"`

Payload:

```json
{ 
  "title": "book5", 
  "link": "http://link-to-book-15.com" 
}
```

Response:

```json
{ 
  "id": "3", 
  "title": "book5", 
  "link": "http://link-to-book-15.com" 
}
```

##### `DELETE /api/books/<id>`

This is the REST API call used to delete a specific book resource, and this kind of request
doesn't need a body and only requires the book id as part of the URL as shown in the next example.

Our REST server will also not return anything, the status code will be enough for us.

Request: `DELETE "<URL>/api/books/2"`

Response:

```json
[]
```

##### Unsuccessful Requests

It is possible that we could send ill-constructed requests, requests on unavailable entities, or
bad or incomplete payloads. For all such instances, we'll use the relevant HTTP error codes.

#### Design Decisions

We have defined our REST API and next we would like to implement the server. It is important to
plan what we want our server to accomplish prior to writing any code. Here are some specs:

* We need to extract `<id>` for `PUT`, `DELETE`, and single resource `GET` requests.
* We want to log every incoming request.
* It would be tedious and bad practice to duplicate so much effort. Closures and function
literals will help us to create new functions that will combine the tasks from the previous two
points.
* In order to keep it simple, we'll be using a `map[string]bookResource` to store the state of all
book resources. All ops will be done on this map. IRL, a database is generally used.
* Go server can handle concurrent requests, so let's make sure to be safe from race conditions.

#### The REST Server for Books API

Here's the structure we'll use:

```
$ tree 
. 
├── books-handler 
│   ├── actions.go 
│   ├── common.go 
│   └── handler.go 
└── main.go 
 
1 directory, 5 files
```

##### `main.go`

The `main.go` source consists of code mostly responsible for assembling and running the web
server.

```go
package main

import (
  "fmt"
  "log"
  "net/http"

  "./books-handler"
)

func main() {
  // Get state (map) for books available on REST server.
  books := booksHandler.GetBooks()
  log.Println(fmt.Sprintf("%+v", books))

  actionCh := make(chan booksHandler.Action)

  // Start goroutine responsible for handling interaction with the books map
  go booksHandler.StartBooksManager(books, actionCh)

  http.HandleFunc("/api/books/", booksHandler.MakeHandler(booksHandler.BookHandler, "/api/books/", actionCh))

  log.Println("Starting server at port 8080...")
  http.ListenAndServe(":8080", nil)
}
```

##### `books-handler/common.go`

The code in this source fill is generic logic, which may be shared across multiple requests.

💡 _It is generally a good practice to identify the logic that is not tied to one particular
handler and then move it into common.go or a similar source file(s), as this would make them
easier to find and reduce duplicated code._

```go
package booksHandler

import (
  "encoding/json"
  "fmt"
  "log"
  "net/http"
)

// bookResource is used to hold all data needed to represent a Book resource in the books map.
type bookResource struct {
  Id    string "json:\"id\""
  Title string "json:\"title\""
  Link  string "json:\"link\""
}

// requestPayload is used to parse request's Payload. We ignore Id field for simplicity.
type requestPayload struct {
  Title string "json:\"title\""
  Link  string "json:\"link\""
}

// response struct consists of all the information required to create the correct HTTP response.
type response struct {
  StatusCode int
  Books      []bookResource
}

// Action struct is used to send data to the goroutine managing the state (map) of books.
// RetChan allows us to send data back to the Handler function so that we can complete the HTTP request.
type Action struct {
  Id      string
  Type    string
  Payload requestPayload
  RetChan chan<- response
}

// GetBooks is used to get the initial state of books represented by a map.
func GetBooks() map[string]bookResource {
  books := map[string]bookResource{}
  for i := 1; i < 6; i++ {
    id := fmt.Sprintf("%d", i)
    books[id] = bookResource{
      Id:    id,
      Title: fmt.Sprintf("Book-%s", id),
      Link:  fmt.Sprintf("http://link-to-book%s.com", id),
    }
  }
  return books
}

// MakeHandler shows a common pattern used reduce duplicated code.
func MakeHandler(fn func(http.ResponseWriter, *http.Request, string, string, chan<- Action),
  endpoint string, actionCh chan<- Action) http.HandlerFunc {

  return func(w http.ResponseWriter, r *http.Request) {
    path := r.URL.Path
    method := r.Method

    msg := fmt.Sprintf("Received request [%s] for path: [%s]", method, path)
    log.Println(msg)

    id := path[len(endpoint):]
    log.Println("ID is ", id)
    fn(w, r, id, method, actionCh)
  }
}

// writeResponse uses the pattern similar to MakeHandler.
func writeResponse(w http.ResponseWriter, resp response) {
  var err error
  var serializedPayload []byte

  if len(resp.Books) == 1 {
    serializedPayload, err = json.Marshal(resp.Books[0])
  } else {
    serializedPayload, err = json.Marshal(resp.Books)
  }

  if err != nil {
    writeError(w, http.StatusInternalServerError)
    fmt.Println("Error while serializing payload: ", err)
  } else {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(resp.StatusCode)
    w.Write(serializedPayload)
  }
}

// writeError allows us to return error message in JSON format.
func writeError(w http.ResponseWriter, statusCode int) {
  jsonMsg := struct {
    Msg  string "json:\"msg\""
    Code int    "json:\"code\""
  }{
    Code: statusCode,
    Msg:  http.StatusText(statusCode),
  }

  if serializedPayload, err := json.Marshal(jsonMsg); err != nil {
    http.Error(w, http.StatusText(http.StatusInternalServerError), http.StatusInternalServerError)
    fmt.Println("Error while serializing payload: ", err)
  } else {
    w.Header().Set("Content-Type", "application/json")
    w.WriteHeader(statusCode)
    w.Write(serializedPayload)
  }
}
```

##### `books-handler/actions.go`

This source file consists of functions to handle each of the HTTP request's method calls:

```go
package booksHandler

import (
  "net/http"
)

// actOn{GET, POST, DELETE, PUT} functions return Response based on specific Request type.

func actOnGET(books map[string]bookResource, act Action) {
  // These initialized values cover the case:
  // Request asked for an id that doesn't exist.
  status := http.StatusNotFound
  bookResult := []bookResource{}

  if act.Id == "" {

    // Request asked for all books.
    status = http.StatusOK
    for _, book := range books {
      bookResult = append(bookResult, book)
    }
  } else if book, exists := books[act.Id]; exists {

    // Request asked for a specific book and the id exists.
    status = http.StatusOK
    bookResult = []bookResource{book}
  }

  act.RetChan <- response{
    StatusCode: status,
    Books:      bookResult,
  }
}

func actOnDELETE(books map[string]bookResource, act Action) {
  book, exists := books[act.Id]
  delete(books, act.Id)

  if !exists {
    book = bookResource{}
  }

  // Return the deleted book if it exists else return an empty book.
  act.RetChan <- response{
    StatusCode: http.StatusOK,
    Books:      []bookResource{book},
  }
}

func actOnPUT(books map[string]bookResource, act Action) {
  // These initialized values cover the case:
  // Request asked for an id that doesn't exist.
  status := http.StatusNotFound
  bookResult := []bookResource{}
  // If the id exists, update its values with the values from the payload.
  if book, exists := books[act.Id]; exists {
    book.Link = act.Payload.Link
    book.Title = act.Payload.Title
    books[act.Id] = book

    status = http.StatusOK
    bookResult = []bookResource{books[act.Id]}
  }

  // Return status and updated resource.
  act.RetChan <- response{
    StatusCode: status,
    Books:      bookResult,
  }

}

func actOnPOST(books map[string]bookResource, act Action, newID string) {
  // Add the new book to 'books'.
  books[newID] = bookResource{
    Id:    newID,
    Link:  act.Payload.Link,
    Title: act.Payload.Title,
  }

  act.RetChan <- response{
    StatusCode: http.StatusCreated,
    Books:      []bookResource{books[newID]},
  }
}
```

##### `books-handler/handler.go`

The `handler.go` source file consists of all logic required to work with and handle book requests.
Apart from consisting the logic for handling HTTP requests, it also deals with maintaining the
state of the books on the server.

```go
package booksHandler

import (
  "encoding/json"
  "fmt"
  "io/ioutil"
  "log"
  "net/http"
)

// StartBooksManager starts a goroutine that changes the state of books (map).
// Primary reason to use a goroutine instead of directly manipulating the books map is to ensure
// that we do not have multiple requests changing books' state simultaneously.
func StartBooksManager(books map[string]bookResource, actionCh <-chan Action) {
  newID := len(books)
  for {
    select {
    case act := <-actionCh:
      switch act.Type {
      case "GET":
        actOnGET(books, act)
      case "POST":
        newID++
        newBookID := fmt.Sprintf("%d", newID)
        actOnPOST(books, act, newBookID)
      case "PUT":
        actOnPUT(books, act)
      case "DELETE":
        actOnDELETE(books, act)
      }
    }
  }
}

/* BookHandler is responsible for ensuring that we process only the valid HTTP Requests.

 * GET -> id: Any

 * POST -> id: No
 *      -> payload: Required

 * PUT -> id: Any
 *     -> payload: Required

 * DELETE -> id: Any
 */
func BookHandler(w http.ResponseWriter, r *http.Request, id string, method string, actionCh chan<- Action) {

  // Ensure that id is set only for valid requests
  isGet := method == "GET"
  idIsSetForPost := method == "POST" && id != ""
  isPutOrPost := method == "PUT" || method == "POST"
  idIsSetForDelPut := (method == "DELETE" || method == "PUT") && id != ""
  if !isGet && !(idIsSetForPost || idIsSetForDelPut || isPutOrPost) {
    writeError(w, http.StatusMethodNotAllowed)
    return
  }

  respCh := make(chan response)
  act := Action{
    Id:      id,
    Type:    method,
    RetChan: respCh,
  }

  // PUT & POST require a properly formed JSON payload
  if isPutOrPost {
    var reqPayload requestPayload
    body, _ := ioutil.ReadAll(r.Body)
    defer r.Body.Close()

    if err := json.Unmarshal(body, &reqPayload); err != nil {
      writeError(w, http.StatusBadRequest)
      return
    }

    act.Payload = reqPayload
  }

  // We have all the data required to process the Request.
  // Time to update the state of books.
  actionCh <- act

  // Wait for respCh to return data after updating the state of books.
  // For all successful Actions, the HTTP status code will either be 200 or 201.
  // Any other status code means that there was an issue with the request.
  var resp response
  if resp = <-respCh; resp.StatusCode > http.StatusCreated {
    writeError(w, resp.StatusCode)
    return
  }

  // We should only log the delete resource and not send it back to user
  if method == "DELETE" {
    log.Println(fmt.Sprintf("Resource ID %s deleted: %+v", id, resp.Books))
    resp = response{
      StatusCode: http.StatusOK,
      Books:      []bookResource{},
    }
  }

  writeResponse(w, resp)
}
```

💡 _Even though we have created a REST server from scratch, it is incomplete. To make writing a
REST server feasible, a lot of important details have been left out. IRL, we should use one of
the existing libs that will help us build a proper REST server._

So far so good, but how do we interact with a REST server and with the server based on the code
we have seen so far? We'll find out in the next section.

## How to Make REST Calls

### cURL

We'll use `-L` to follow redirects. We'll also be using the `jq` utility for better commandline
formatting of JSON data. On `macOS`, use HomeBrew to install it.

```
brew install jq
```

Visit the [jq download page][jq] for more details on how to install it on other systems.


#### GET

Let's grab the index:

```
$ curl -L localhost:8080/api/books | jq
```

```json
[
  {
    "id": "2",
    "title": "Book-2",
    "link": "http://link-to-book2.com"
  },
  {
    "id": "3",
    "title": "Book-3",
    "link": "http://link-to-book3.com"
  },
  {
    "id": "4",
    "title": "Book-4",
    "link": "http://link-to-book4.com"
  },
  {
    "id": "5",
    "title": "Book-5",
    "link": "http://link-to-book5.com"
  },
  {
    "id": "1",
    "title": "Book-1",
    "link": "http://link-to-book1.com"
  }
]
```

Let's now grab a single resource for book id 3:

```
$ curl localhost:8080/api/books/3 | jq
```

```json
{
  "id": "3",
  "title": "Book-3",
  "link": "http://link-to-book3.com"
}
```

#### DELETE

Assuming that we have a book with the id "2", we can delete it using cURL, as follows:

```
$ curl -LX DELETE localhost:8080/api/books/2 | jq

[]
```

Now notice the book with id 2 is no longer available:

```
$ curl -L localhost:8080/api/books | jq
```

```json
[
  {
    "id": "3",
    "title": "Book-3",
    "link": "http://link-to-book3.com"
  },
  {
    "id": "4",
    "title": "Book-4",
    "link": "http://link-to-book4.com"
  },
  {
    "id": "5",
    "title": "Book-5",
    "link": "http://link-to-book5.com"
  },
  {
    "id": "1",
    "title": "Book-1",
    "link": "http://link-to-book1.com"
  }
]
```

#### PUT

Let's update an existing book resource with the id "4":

```
$ curl -H "Content-Type: application/json" -LX PUT -d '{"title": "New Book Title", "link": "New Link"}' localhost:8080/api/books/4 | jq
```

```json
{
  "id": "4",
  "title": "New Book Title",
  "link": "New          Link"
}
```

So now book 4 should have an updated title and link:

```
$ curl -L localhost:8080/api/books/4 | jq
```

```json
{
  "id": "4",
  "title": "New Book Title",
  "link": "New Link"
}
```

#### POST

Now that we know how to send a payload using cURL, let's create a new book resource:

```
curl -H "Content-Type: application/json" -LX POST -d '{"title":"Ultra New Book", "link": "Ultra New Link"}' localhost:8080/api/books/ | jq
```

```json
{
  "id": "6",
  "title": "Ultra New Book",
  "link": "Ultra New Link"
}
```

Here are the commands for quick reference:

* `curl -L localhost:8080/api/books | jq # GET CALL`
* `curl localhost:8080/api/books/3 | jq # GET a single resource.`
* `curl -LX DELETE localhost:8080/api/books/2 | jq # DELETE a resource.`
* `curl -H "Content-Type: application/json" -LX PUT -d '{"title": "New Book Title", "link": "New Link"}' localhost:8080/api/books/4 | jq`
* `curl -H "Content-Type: application/json" -LX POST -d '{"title":"Ultra New Book", "link": "Ultra New Link"}' localhost:8080/api/books/ | jq # POST ie., create a new resource.`

And that's the basic idea behind a REST server and how a client will interact with it.

### Postman

_Skipped._

### `net/http`

Now let's look at how to send `GET` and `POST` from go:

```go
package main

import (
  "bytes"
  "encoding/json"
  "fmt"
  "io/ioutil"
  "net/http"
)

type bookResource struct {
  Id    string "json:\"id\""
  Title string "json:\"title\""
  Link  string "json:\"link\""
}

func main() {
  // GET
  fmt.Println("Making GET call.")
  // It is possible that we might have error while making an HTTP request
  // due to too many redirects or HTTP protocol error. We should check for this eventuality.
  resp, err := http.Get("http://localhost:8080/api/books")
  if err != nil {
    fmt.Println("Error while making GET call.", err)
    return
  }

  fmt.Printf("%+v\n\n", resp)

  // The response body is a data stream from the server we got the response back from.
  // This data stream is not in a useable format yet.
  // We need to read it from the server and convert it into a byte stream.
  body, _ := ioutil.ReadAll(resp.Body)
  defer resp.Body.Close()

  var books []bookResource
  json.Unmarshal(body, &books)

  fmt.Println(books)
  fmt.Println("\n")

  // POST
  payload, _ := json.Marshal(bookResource{
    Title: "New Book",
    Link:  "http://new-book.com",
  })

  fmt.Println("Making POST call.")
  resp, err = http.Post(
    "http://localhost:8080/api/books/",
    "application/json",
    bytes.NewBuffer(payload),
  )
  if err != nil {
    fmt.Println(err)
  }

  fmt.Printf("%+v\n\n", resp)

  body, _ = ioutil.ReadAll(resp.Body)
  defer resp.Body.Close()

  var book bookResource
  json.Unmarshal(body, &book)

  fmt.Println(book)

  fmt.Println("\n")
}
```

You should see the following when running this while the REST server is running in the background:

```
Making GET call.
&{Status:200 OK StatusCode:200 Proto:HTTP/1.1 ProtoMajor:1 ProtoMinor:1 Header:map[Content-Length:[311] Content-Type:[application/json] Date:[Sat, 24 Mar 2018 16:35:26 GMT]] Body:0xc420148040 ContentLength:311 TransferEncoding:[] Close:false Uncompressed:false Trailer:map[] Request:0xc420106100 TLS:<nil>}

[{2 Book-2 http://link-to-book2.com} {3 Book-3 http://link-to-book3.com} {4 Book-4 http://link-to-book4.com} {5 Book-5 http://link-to-book5.com} {1 Book-1 http://link-to-book1.com}]


Making POST call.
&{Status:201 Created StatusCode:201 Proto:HTTP/1.1 ProtoMajor:1 ProtoMinor:1 Header:map[Content-Type:[application/json] Date:[Sat, 24 Mar 2018 16:35:26 GMT] Content-Length:[58]] Body:0xc420118200 ContentLength:58 TransferEncoding:[] Close:false Uncompressed:false Trailer:map[] Request:0xc420170000 TLS:<nil>}

{6 New Book http://new-book.com}
```

Check out the [package page for `net/http`][net/http] for more details.

[🔙 Channels and Messages][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Introducing Goophr 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch03-channels-and-messages.md
[upcoming-chapter]: ch05-introducing-goophr.md
[jq]: https://stedolan.github.io/jq/download/
[net/http]: https://golang.org/pkg/net/http/
