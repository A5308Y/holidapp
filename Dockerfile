# Use an official Elixir runtime as a parent image
FROM elixir:latest

RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN apt-get update && apt-get install -y postgresql-client inotify-tools nodejs

# Create app directory and copy the Elixir projects into it
RUN mkdir /app
COPY . /app
WORKDIR /app

# Install hex package manager
RUN mix local.hex --force

# RUN mix deps.clean --all
# RUN mix clean
# RUN mix deps.get
# RUN curl -L -o elm.gz https://github.com/elm/compiler/releases/download/0.19.1/binary-for-linux-64-bit.gz
# RUN gunzip elm.gz
# RUN chmod +x elm
# RUN mv elm /usr/local/bin/
# WORKDIR /app/assets
# RUN npm install --save elm-webpack-loader
# WORKDIR /app
# RUN mix local.rebar --force

# Compile the project
RUN mix deps.clean --all
RUN mix clean
RUN mix deps.get
RUN mix local.rebar --force
RUN mix do compile

# RUN mix phx.digest

CMD ["/app/entrypoint.sh"]
