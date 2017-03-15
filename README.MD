# Dokku Daemon API

HTTP API to interact with  [Dokku Daemon](https://github.com/dokku/dokku-daemon) over HTTP.

## Requirements 

A server running Dokku with Dokku Daemon and Redis plugin installed.

## How it works?

This is a simple Sinatra app which intereacts with Dokku Daemon's Unix socket. It received the commands and passes it to daemon and saves the result. `/var/run/dokku-daemon` folder should be mounted into the application so app can access to the socket.

## Installing

You need to create an app for the API on the server;

    dokku apps:create dokku-api
    dokku redis:create dokku-api
    dokku redis:link dokku-api:dokku-api
    dokku config:set dokku-api API_KEY=YOURAPIKEY API_SECRET=YOURAPISECRET
    
Then you can deploy your app;

    git clone https://github.com/beydogan/dokku-api
    cd dokku-api
    git remote add dokku dokku@yourserver.ip:dokku-api
    git push dokku


## Authentication

Dokku API uses `Api-Key` and `Api-Secret` request headers for authentication. These values are set as environment variables while deploying your app named `API_KEY` and `API_SECRET`. **`Api-Key` and `Api-Secret` headers must be present on all requests**.

## Usage

Dokku API has two endpoints. `POST /run` and `GET /status`

## POST /run

Runs the given command and returns the `command_id`. `command_id` is used for getting the result of command.

**Params**

    cmd -> Command to run
    
**Response** 

```json
    {
      "success": true,
      "command_id": "fe40c1efc41c6b9f8a185be9ee52fffdf92af5bed2c07971fa38cf237be84f4e"
    }
```


## GET /status

Returns the result of a command. 
`GET /status`

**Params**

    command_id -> Command ID of the command
    
**Response** 
    
*apps*

```json
    {
      "status": "success",
      "result": {
        "ok": true,
        "output": "=====> My Apps\napi\nhello_world"
      }
    }
```

*randomcmd*

```json
    {
      "status": "ok",
      "result": {
        "ok": false,
        "output": "Invalid command"
      }
    }
```    
*ps:restart hello_world*

```json
    {
      "status": "error",
      "result": "result_not_ready"
    }
```
