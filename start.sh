#!/bin/bash
bundle exec rake db:create
bundle exec rake db:migrate
bundle exec puma -C config/puma.rb