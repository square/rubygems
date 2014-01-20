Tuf
===

This fork contains an implementation of The Update Framework (TUF).

It requires the server to be running the `tuf-poc` branch from github.com/square/rubygems.org

* Set up the server as described in its README, including pushing a gem.
* Copy `config/root.txt` from the server to the rubygems root directory.
* Edit `$LOAD_PATH` at the top of `lib/rubygems/tuf/fetcher.rb` to point to
  your server install.
* Install a gem:

    ruby -S --disable-gems bin/gem install --tuf \
      --clear-sources --source http://localhost:3000 \
      yourgem
