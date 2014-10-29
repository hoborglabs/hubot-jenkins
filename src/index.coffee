url = require('url')
querystring = require 'querystring'
jenkinsCore = require './core'

module.exports = (robot) ->
	new Jenkins robot

class Jenkins
	constructor: (robot) ->
		@robot = robot
		@config = {}

		if process.env.HUBOT_CIOPERATOR_CONFIG
			@config = require process.env.HUBOT_CIOPERATOR_CONFIG

		@core = jenkinsCore.create @robot.http, @config

		@robot.router.post "/hubot/jenkins-events", (req, res) =>
			@handleJenkinsEvent req, res

		@robot.respond /build(?: job)(.*)/i, (msg) =>
			jobName = msg.match[2]
			@core.build jobName, {}, (what) ->
				msg.send what

		@robot.respond /get(?: job)? ([^ ]+)(?: #(\d+))?/i, (msg) =>
			jobName = msg.match[1]
			jobNumber = msg.match[2] || 'latestStable'
			@core.getJobRun jobName, jobNumber, (what) ->
				msg.send what

	handleJenkinsEvent: (req, res) ->
		data = req.body
		query = querystring.parse(url.parse(req.url).query)
		room = query.room

		try
			@core.announceJenkinsEvent data, (what) =>
				@robot.messageRoom room, what
		catch error
			@robot.messageRoom room, "Whoa, I got an error: #{error}"
			console.log "jenkins event notifier error: #{error}. Request: #{req.body}"

		res.end ""
