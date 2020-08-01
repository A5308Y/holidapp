# Holidapp

To start Holidapp run `docker-compose up`.

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Production Deployment

Run `bash provision_droplet.sh` to create a digital ocean instance and deploy holidapp.

# Tear down

Run `doctl compute droplet delete holidapp-prod` to tear down the digital ocean instance.
