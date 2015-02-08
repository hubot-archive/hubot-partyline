# Hubot Partyline [![Build Status](https://travis-ci.org/hubot-scripts/hubot-partyline.svg)](https://travis-ci.org/hubot-scripts/hubot-partyline)

Adds peer-to-peer (P2P) partyline support to [Hubot](https://github.com/github/hubot).

This enables multiple Hubots to connect to form a partyline, independent of which
Hubot adapter or other service each Hubot uses. In this way, Hubot Partyline can
become a bridge between otherwise incompatible platforms (IRC, Slack, etc).

> NB! This is currently in very early development stages and is currently nothing
> more than a prototype. Proceed with caution.

## Features

### Terminology

* *Peer* - another Hubot node on the network
* *Seed* - a direct peer connection
* *User* - a user anywhere in the network
* *Mute* - stop displaying messages from a user locally
* *Shun* - stop broadcasting messages to a peer
* *Ignore* - do not interact with this user/peer

### Available

* Decentralized P2P network
* Connect seeds via Hubot command

### Planned

* Persist peer data in Hubot brain
* Disconnect seeds via Hubot command
* Authorization support
* Mute users (even across networks)
* Shun peers
* Ignore users
* Peer rating system

## Installation

`npm install hubot-partyline`

Then add `"hubot-partyline"` to your Hubot's `external-scripts.json`

## Configuration

`HUBOT_PARTYLINE_PORT` - Default: 8879

## Commands

`hubot partyline add seed <host>:<port>` - add a peer and connect to it.
