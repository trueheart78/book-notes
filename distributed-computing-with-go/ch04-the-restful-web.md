[🔙 Channels and Messages][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Introducing Goophr 🔜][upcoming-chapter]

# Chapter 4. The RESTful Web

## HTTP and Sessions

### A Brief History of HTTP

### HTTP Sessions

## The REST Protocol

### The Server and Client Architecture

### The Standard Data Format

### Resources

### Reusing the HTTP Protocol

#### GET

#### POST

#### PUT and PATCH

#### DELETE

### Upgradable Components

## Fundamentals of a REST Server

### A Simple Web Server

### Designing a REST API

#### The Data Format

##### The Book Resource

##### `GET /api/books`

##### `GET /api/books/<id>`

##### `POST /api/books`

##### `PUT /api/books/<id>`

##### `DELETE /api/books/<id>`

##### Unsuccessful Requests

#### Design Decisions

#### The REST Server for Books API

##### `main.go`

##### `books-handler/common.go`

##### `books-handler/actions.go`

##### `books-handler/handler.go`

## How to Make REST Calls

### cURL

#### GET

#### DELETE

#### PUT

#### POST

### Postman

### `net/http`

[🔙 Channels and Messages][previous-chapter]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[🏡][readme]&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;[Introducing Goophr 🔜][upcoming-chapter]

[readme]: README.md
[previous-chapter]: ch03-channels-and-messages.md
[upcoming-chapter]: ch05-introducing-goophr.md
