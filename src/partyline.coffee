# Description
#   Decentralized P2P partyline support for Hubot
#
# Dependencies:
#   hubot-auth
#
# Configuration:
#   HUBOT_PARTYLINE_PORT - which port the partyline will bind to [default: 8879]
#
# Commands:
#
# Author:
#   therealklanni

{inspect} = require 'util'
port = process.env.HUBOT_PARTYLINE_PORT || 8879

module.exports = (robot) ->
  debug = robot.logger.debug

  coal = require 'coalescent'
  app = coal()

  app.use coal.tattletale()
  app.use coal.courier()
  app.use coal.router()

  app.route 'message', (sock, msg) ->
    robot.logger.debug "Partyline Incoming message: #{msg}"
    robot.logger.debug inspect sock

  app.on 'error', (err, sock) ->
    robot.logger.debug err, inspect sock

  app.on 'peerConnected', (peer) ->
    robot.logger.debug "Partyline Connected to peer"
    robot.logger.debug inspect peer

  app.on 'peerDisconnected', (peer) ->
    robot.logger.debug "Partyline Disconnected from peer"

  robot.brain.on 'loaded', ->
    robot.logger.debug 'Partyline loaded'

  robot.hear /^(?!hubot ).+/i, (msg) ->
    user = msg.message.user
    robot.logger.debug "Partyline received message from #{user.name}(#{user.id}): #{msg.match[0]}"
    robot.logger.debug inspect msg.message
    app.broadcast 'message', msg.message

  robot.respond /partyline add seed (.+)/i, (msg) ->
    robot.logger.debug "Partyline adding peer #{msg.match[1]}"
    app.set 'seeds', app.options.seeds.concat msg.match[1]

  app.listen port
  robot.logger.debug "Partyline initialized, listening on port #{port}"
