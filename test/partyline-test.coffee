chai = require 'chai'
sinon = require 'sinon'
proxy = require 'proxyquire'
chai.use require 'sinon-chai'
expect = chai.expect

Robot = require 'hubot/src/robot'
TextMessage = require('hubot/src/message').TextMessage

logStub =
  info: ->
  error: ->
  log: ->
  warn: ->

describe 'Partyline', ->
  robot = {}
  admin_user = {}
  role_user = {}
  anon_user = {}
  adapter = {}
  coal = require 'coalescent'
  app = {}
  app2 = {}
  port = 24842
  port2 = 13531

  beforeEach (done) ->
    app2 = coal({ logger: logStub })
    app2.use coal.tattletale()
    app2.use coal.courier()
    app2.use coal.router()
    app2.recvStub = sinon.stub()
    app2.peerStub = sinon.stub()
    app2.route 'message', app2.recvStub
    app2.on 'peerConnected', app2.peerStub

    proxyOpts =
      'coalescent': ->
        app = coal({ logger: logStub })
        app.use coal.tattletale()
        app.use coal.courier()
        app.use coal.router()
        sinon.spy app, 'listen'
        sinon.spy app, 'route'
        sinon.spy app, 'on'
        sinon.spy app, 'set'
        app

    process.env.HUBOT_AUTH_ADMIN = '1'
    process.env.HUBOT_PARTYLINE_PORT = ++port

    # Create new robot, without http, using mock adapter
    robot = new Robot null, 'mock-adapter', false

    robot.adapter.on 'connected', ->

      # load the module under test and configure it for the
      # robot. This is in place of external-scripts
      proxy('../src/partyline', proxyOpts)(robot)

      admin_user = robot.brain.userForId '1', {
        name: 'admin-user'
        room: '#test'
      }

      role_user = robot.brain.userForId '2', {
        name: 'role-user'
        room: '#test'
      }

      anon_user = robot.brain.userForId '3', {
        name: 'anon-user'
        room: '#test'
      }

      adapter = robot.adapter

    sinon.spy robot, 'hear'
    sinon.spy robot, 'respond'
    robot.run()

    done()

  afterEach ->
    robot.shutdown()

  it 'initializes', ->
    expect(app.route).to.have.been.calledWith 'message'
    expect(app.on).to.have.been.calledWith 'error'
    expect(app.on).to.have.been.calledWith 'peerConnected'
    expect(app.on).to.have.been.calledWith 'peerDisconnected'
    expect(app.listen).to.have.been.calledWith port.toString()

    expect(robot.hear).to.have.been.calledWith /^(?!Hubot ).+/i
    expect(robot.respond).to.have.been.calledWith /partyline add seed (.+)/i

  it 'connects to a seed when hubot receives the add seed command', (done) ->
    app2.listen ++port2

    adapter.receive(new TextMessage admin_user, "hubot: partyline add seed localhost:#{port2}")
    expect(app.set).to.have.been.calledWithMatch 'seeds', sinon.match.array
    app._enterNetwork()

    setTimeout ->
      expect(app2.peerStub).to.have.been.called
      expect(app2.connections.inbound.length).to.equal 1
      done()
    , 50

  it 'receives inbound connections', (done) ->
    app.on 'peerConnected', ->
      expect(app.connections.inbound.length).to.equal 1

    app2.connect port, ->
      done()

  it 'broadcasts chat messages to connected peers', (done) ->
    sinon.spy app, 'broadcast'

    app2.listen ++port2

    adapter.receive(new TextMessage admin_user, "hubot: partyline add seed localhost:#{port2}")
    app._enterNetwork()

    setTimeout ->
      expect(app.connections.outbound.length).to.equal 1
      expect(app2.connections.inbound.length).to.equal 1
      expect(app2.peerStub).to.have.been.called

      adapter.receive(new TextMessage anon_user, 'this is a test')
      expect(app.broadcast).to.have.been.calledWithMatch 'message', { text: 'this is a test' }
      setTimeout ->
        expect(app2.recvStub).to.have.been.calledWithMatch sinon.match.any, { body: { text: 'this is a test' }}
        done()
      , 50
    , 50
