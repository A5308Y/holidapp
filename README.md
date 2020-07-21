# Holidapp

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).


# Deployment

- `doctl compute droplet create --region fra1 --image ubuntu-20-04-x64 --size s-1vcpu-1gb holidapp-prod --ssh-keys 797406`
- `ssh root@<IP>`
- `useradd -m -s /bin/bash holidapp`
- `cp /root/.ssh /home/holidapp`
- `chown -R holidapp /home/holidapp`
- `usermod -aG sudo holidapp`
- `passwd holidapp`
- `ssh holidapp@<IP>`
- `sudo apt update`
- `sudo apt install apt-transport-https ca-certificates curl software-properties-common`
- `curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -`
- `sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable"`
- `sudo apt update`
- `apt-cache policy docker-ce`
- `sudo apt install docker-ce`
-  CHECK `sudo systemctl status docker`
- `sudo usermod -aG docker holidapp`
- `su - holidapp`
-  CHECK `id -nG`
- `sudo curl -L "https://github.com/docker/compose/releases/download/1.26.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose`
-  CTRL-D
- `scp -r data docker-compose.prod.yml .env-prod Dockerfile init-letsencrypt.sh holidapp@<IP>:`
- `ssh holidapp@<IP>`
- `mv docker-compose.prod.yml docker-compose.yml`
- `bash init-letsencrypt.sh`
- `docker-compose -f docker-compose.yml up -d`

# Tear down

Run `doctl compute droplet delete holidapp-prod` to tear down the digital ocean instance.
