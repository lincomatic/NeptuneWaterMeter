# Raspberry Pi tracker for Neptune R900 smart water meters
### Works for City of Atlanta and many other municipalities

## This fork posts to InfluxDB instead of a google spreadsheet

## Introduction

The goals of this project are:
- Use a Raspberry Pi and a RTL-SDR to track my smart water meter (Read: cheap, less than $50)
- Docker to simplify the installation and setup of RTLAMR
- Resin.io to deploy this docker container to the Raspberry Pi in my house
- Logging to a Google Spreadsheet so house members can track usage

## Credit

- @mdp - this fork is just a hack of his https://github.com/mdp/AtlantaWaterMeter
- @besmasher - Built the excellent [RTLAMR](https://github.com/bemasher/rtlamr) library which actually does all the work of reading the meters.
- [Frederik Granna's](https://bitbucket.org/fgranna/) docker base for setting up RTL-SDR on the Raspberry Pi

## Requirements

- Raspberry Pi 3 (Might work on others, only tested on the 3)
- [RTL-SDR](https://www.amazon.com/NooElec-NESDR-Mini-Compatible-Packages/dp/B009U7WZCA)
- [Resin.io](https://resin.io) for deployment and installation to the Raspberry pi

### Technical chops

You'll need to be able to do the following to get this to work:

- Clone and push a repository with 'git'
- Write a disk image to an SD card
- Basic script editing

## Installation

1. Signup for [Resin.io](https://resin.io)
1. Create a new Application and download the image for the Raspberry Pi
1. Install the image on the Raspberry Pi
1. Plug in your RTL-SDR into the USB port on the Raspberry Pi
1. `git push` this repository to your Resin application
1. In Resin, view the logs on your device and find your meter ID. This is hardest part. You'll need to know your current reading to match it up to the meter ID. I've not found any correlation between what's written on the meter and the ID being sent out over the air.
1. Once you find your meter ID, enter it as an environment variable in the Resin dashboard under "METERID"
1. enter the URI of your InfluxDB, e.g. http://192.168.1.25:8086 under "URI"
1. At this point it's up to you as to how you want to view the data. I use Grafana

## InfluxDB

1. database is "h2o"
1. meter reading is stored as "gal"
1. meter id = "id"