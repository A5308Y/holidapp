# Holidapp

To start Holidapp locally for development purposes run `docker-compose up`.
If you want to work on the frontend run `yarn --cwd assets run watch` as well (in a different terminal).

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

# Production Deployment

Run `bash provision_droplet.sh` to create a digital ocean instance and deploy holidapp.

# Tear down

Run `doctl compute droplet delete holidapp-prod` to tear down the digital ocean instance.
