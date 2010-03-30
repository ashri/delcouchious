Delcouchious
===========

A [Sinatra][1] application which provides a replica of the Delicious API through which [Pukka][2] can send bookmarks to it
and have them stored in [CouchDB][3].

There are some basic pages for viewing a home page of stored bookmarks, a bookmarks with specific tags.


Getting Started
---------------

- Configure the config.yml file with a *username* (not used for anything but included in the XML sent back to Pukka) and
  the name of the CouchDB *database*.
- Ensure the database is created in your CouchDB instance.
- Add the view design documents to CouchDB found in the *couchdb_design_docs.json* file.
- Start the Sinatra server in any Rack-supporting environment and navigate to the home page (eg. http://localhost:4567/)

- In Pukka, in the advanced preferences, configure the API URL as `http://<servername or localhost>:<port>`
- Bookmark a series of web pages using Pukka

Special Tags
------------

There are two special tags looked for when the application renders the home page, *speeddial* and *toread*. URLs added with
those tags will appear in special sections on the home page.



LICENSE
-------

Delcouchious is Copyright (c) 2010 Ashley Richardson and distributed under the MIT license. See the COPYING file for
more info.


[1]: http://www.sinatrarb.com/
[2]: http://codesorcery.net/pukka
[3]: http://couchdb.apache.org
