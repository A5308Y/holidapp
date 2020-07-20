# Holidapp

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


# Deployment

- Create a droplet with `docker-machine create --digitalocean-size "s-1vcpu-1gb" --driver digitalocean --digitalocean-access-token PERSONAL_ACCESS_TOKEN holidapp-prod`
- Followed by `eval $(docker-machine env holidapp-prod)` to connect to the droplet.
- and `docker-compose -f docker-compose.prod.yml up -d` to install and start the app.
- Find out the ip taken from the URL displayed by `docker-machine ls`. (http://xxx.xxx.xxx.xxx)

# Tear down

Run `docker-machine rm holidapp-prod` to tear down the digital ocean instance.
