# Dokku Vendor Server

A simple sinatra app that acts like `BUILDPACK_VENDOR_URL` and downloads requested file to local and serves the file for dokku deploys. Like ruby binaries, bundler etc.

# Why?
I'm deploying Rails apps to dokku-powered DO servers located in AMS1 and SGP1, it takes more than 5 or 6 minutes each deploy because its downloading Ruby binaries each time. Its faster if you server from local.

# Installation

*only tested for heroku-buildpack-ruby*

* Deploy this app to your dokku server.

```bash
#server
dokku apps:create dokku-vendor
#local
git clone git@github.com:beydogan/dokku-vendor.git
cd dokku-vendor
git remote add dokku dokku@SERVER-IP:dokku-vendor
```

* Create a persistent storage binded to `/tmp/dokku-vendor`


```bash
#server
sudo mkdir /dokku-vendor
sudo chown dokku /dokku-vendor
dokku storage:mount dokku-vendor /dokku-vendor:/tmp/dokku-vendor
```

* Use your app url as `BUILDPACK_VENDOR_URL` to your other apps.

```bash
#server
dokku config:set my-rails-app --no-restart BUILDPACK_VENDOR_URL=SERVER-IP:PORT/heroku-buildpack-ruby/
```
