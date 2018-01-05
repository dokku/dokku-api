# Dokku API

HTTP API to interact with  [Dokku Daemon](https://github.com/dokku/dokku-daemon) over HTTP.

## Requirements

A server running Dokku with Dokku Daemon and Redis, Postgres plugin installed.

## How it works?

This is a simple Sinatra app which intereacts with Dokku Daemon's Unix socket. It received the commands and passes it to daemon and saves the result. `/var/run/dokku-daemon` folder should be mounted into the application so app can access to the socket.

## Installing

You need to create an app for the API on the server;

    dokku apps:create dokku-api
    dokku redis:create dokku-api
    dokku postgres:create dokku-api
    dokku redis:link dokku-api dokku-api
    dokku postgres:link dokku-api dokku-api
    dokku storage:mount dokku-api /var/run/dokku-daemon:/var/run/dokku-daemon
    dokku ps:scale dokku-api worker=1 

Then you can deploy your app;

    git clone https://github.com/dokku/dokku-api
    cd dokku-api
    git remote add dokku dokku@yourserver.ip:dokku-api
    git push dokku


## Authentication

Dokku API uses `Api-Key` and `Api-Secret` request headers for authentication. **`Api-Key` and `Api-Secret` headers must be present on all requests**.

You can generate a key pair with `rake keys:generate` command.

    dokku run dokku-api rake keys:generate
    >   New API key was generated
    >   API KEY: b33e456232bba2edb8d5cde370bc2f35 | API SECRET: a46287c12099fdd55f0c9513be0cdb32


### Headers

| Name    | Type   | Description                                  |
| ------- | ------ | -------------------------------------------- |
| Api-Key    | string | **Required**                              |
| Api-Secret    | string | **Required**                              |

## Usage

### Retrive all commands

`GET /commands`

**Example**

    curl -i -H "Api-Key: YOURKEY" -H "Api-Secret: YOURSECRET" http://yourserver.ip:42143/commands

**Response**

```json
[
  {
    "id": 1,
    "token": "5069a9ff27219462df6743e6a8b635610cd6c6757ca224605713f89d7e3375be",
    "command": "randomcmd",
    "created_at": "2017-03-15T15:13:45+00:00",
    "ran_at": "2017-03-15T15:13:45+00:00",
    "result_data": {
      "ok": false,
      "output": "Invalid command"
    }
  },
  {
    "id": 2,
    "token": "6b0d56b05b5946b5d18c7f8a8891150d52f7e48a354cf8dcd96800b85340dcb3",
    "command": "apps",
    "created_at": "2017-03-15T15:14:47+00:00",
    "ran_at": "2017-03-15T15:14:49+00:00",
    "result_data": {
      "ok": true,
      "output": "=====> My Apps\napi\ndokku-api\nhello_world"
    }
  }
]
```

## Run a command

`POST /commands`

Adds the given command to the queue and returns the `Command` as json.

**Params**

| Name    | Type   | Description                                  |
| ------- | ------ | -------------------------------------------- |
| cmd    | string | **Required**. Command to run.       |
| sync    | string | **Optional**. **true** or **false** Default false. Runs the command synchronously.    |
| callback_url    | string | **Optional**. The URL to hit after command has been ran   |


**Example**

    curl -i -X POST -d "cmd=apps" -H "Api-Key: YOURKEY" -H "Api-Secret: YOURSECRET" http://yourserver.ip:42143/commands

**Response**

```json
  {
    "id": 2,
    "token": "6b0d56b05b5946b5d18c7f8a8891150d52f7e48a354cf8dcd96800b85340dcb3",
    "command": "apps",
    "created_at": "2017-03-15T15:14:47+00:00",
    "ran_at": null,
    "result_data": null
  }
```


## Retrieve a command

`GET /commands/:token`

Returns the `Command` with given token

**Example**

    curl -i -H "Api-Key: YOURKEY" -H "Api-Secret: YOURSECRET" http://yourserver.ip:42143/commands/6b0d56b05b5946b5d18c7f8a8891150d52f7e48a354cf8dcd96800b85340dcb3

**Params**

| Name    | Type   | Description                                  |
| ------- | ------ | -------------------------------------------- |
| token    | string | **Required**. Token of the command.       |

**Response**

```json
{
  "id": 3,
  "token": "6b0d56b05b5946b5d18c7f8a8891150d52f7e48a354cf8dcd96800b85340dcb3",
  "command": "apps",
  "created_at": "2017-03-15T15:14:47+00:00",
  "ran_at": "2017-03-15T15:14:49+00:00",
  "result_data": {
    "ok": true,
    "output": "=====> My Apps\napi\ndokku-api\nhello_world"
  }
}
```


## Callbacks

If you pass `callback_url` parameter when creating a command, dokku-api will send a POST request to the specified URL with the following JSON schema

```json
{
  "id": 3,
  "token": "6b0d56b05b5946b5d18c7f8a8891150d52f7e48a354cf8dcd96800b85340dcb3",
  "command": "apps",
  "created_at": "2017-03-15T15:14:47+00:00",
  "ran_at": "2017-03-15T15:14:49+00:00",
  "result_data": {
    "ok": true,
    "output": "=====> My Apps\napi\ndokku-api\nhello_world"
  }
}
```
