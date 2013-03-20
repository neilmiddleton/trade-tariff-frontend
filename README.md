# TradeTariffFrontend

[![Build Status](https://travis-ci.org/alphagov/trade-tariff-frontend.png?branch=master)](https://travis-ci.org/alphagov/trade-tariff-frontend)

A web application front end for use with the UK Trade Tariff API.
Please ensure the API is running and properly configured in the 
environment files.

Assumes the GDS development envrionment is setup via puppet.

## Run TradeTariffFrontend

    ./startup.sh

## Specs

To run the spec use the following command: 

    govuk_setenv tariff env RAILS_ENV=test bundle exec rake ci:setup:rspec spec assets:clean assets:precompile
