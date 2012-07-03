# CASServer::Strategy::Impostor

Provides mechanism to steal identity given certain rules. This scenario is most likely not suitable to your workflow.

## Installation

Ensure this gem is reachable by rubycas server, which depends on how you run it.

If you run rubycase-server as sinatra, be it alone or mounted to another app - add this line to Gemfile:

    gem 'rubycas-strategy-impostor', :git => git://github.com/Slotos/rubycas-strategy-impostor.git

And then execute:

    bundle

If you run is as centralized system service - install gem by running:

    gem install rubycas-strategy-impostor

Of course I lied, there's no way to install it that way unless I release it as a gem =P

## Usage

For now you'll have to use my fork of rubycas-server if you want to use this strategy. All you need to do is add this definition to your config.yml (database line is Sequel compatible):

````yaml
strategies:
  -
    strategy: Impostor
    database:
      adapter: sqlite
      database: spec.sqlite
    user_table: users
    role_table: roles
    join_table: roles_users
    user_key: user_id
    role_key: role_id
    username_column: email
    role_name_column: name
    allowed_roles:
      - admin
      - support
      - moderator
````

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
