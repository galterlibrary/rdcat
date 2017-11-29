== System dependencies
* JDK 1.8.x
* Elasticsearch 5.x
* Postgresql 9.x or 10.x
* Development tools, curl-devel, postgresql-devel, httpd-devel, apr-devel, apr-util-devel

== Deployment instructions
* Install stable version of RVM for `deploy` user
* Put RVM in your environment `source /home/deploy/.rvm/scripts/rvm`
* Install ruby: `rvm install ruby-2.4.2`
* Create the gemset: `rvm ruby-2.4.2 do rvm gemset create rdcat`
* Install bundler: `rvm 2.4.2@rdcat do gem install bundler`
* You might need to run `Dataset.reindex!` from rails console after
  the first deployment.
