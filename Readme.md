README
======

Example 'social like' redis app, features include:

* User creation
* Updates
* Friends
* Activity feed
* Online status

Note this is a demo app and as such there are a few obvious issues, such as it is possible to create blank users/updates or two users with the same name.
I decided to keep the app simple for ease of understanding, rather than making it prod ready.


Setup
-----

N.b. This requires ruby, rubygems and bundler to run. Once you have these then run:

* bundle install
* bundle exec shotgun
* visit localhost:9393

N.b. This uses redis as the DB and will currently use DB 0 for the app and DB 1 for the tests
*WARNING* Db 1 will be flushed when running the tests!

Console
-------

To access the console:

* bundle exec racksh

Tests
-----

To run the test suite:

* bundle exec rake
