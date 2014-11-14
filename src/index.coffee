# Commands:
#   hubot get <jenkins-job-name> - Reply with lastes stable job build details
#   hubot get job <jenkins-job-name> - Reply with lastes stable job build details
#   hubot get <jenkins-job-name> #<build-number> - Reply with details of a specific build number
#   hubot get job <jenkins-job-name> #<build-number> - Reply with details of a specific build number

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

		# get [job] test-job [#51]
		@robot.respond /get(?: job)? ([^ ]+)(?: #(\d+))?/i, (msg) =>
			jobName = msg.match[1]
			jobNumber = msg.match[2] || 'lastBuild'
			@getJob jobName, jobNumber, msg

		# build|run [job] test-job
		@robot.respond /(?:build|run)(?: job)? ([^ ]+) ?(.*)/i, (msg) =>
			@buildJob msg.match[1], msg.match[2], msg

		@robot.respond /(?:rebuild|rerun)(?: job)? ([^ ]+)(?: #(\d+))?/i, (msg) =>
			@rebuildJob msg.match[1], msg

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

	buildJob: (jobName, parameters, msg) ->
		@core.build jobName, parameters, (err, buildData) ->
			if err
				return msg.send "Oops, starting job failed #{err}"

			msg.send "Added job #{buildData.fullDisplayName} - #{buildData.url}"

	rebuildJob: (jobName, msg) ->
		@core.rebuild jobName, {}, (err, buildData) ->
			if err
				return msg.send "Oops, rebuilding job failed - #{err}"

			msg.send "Job #{buildData.name} restarted. #{buildData.url}"

	getJob: (jobName, jobNumber, msg) ->
		statusMap =
			SUCCESS: 'was finished successfuly'
			ABORTED: 'was aborted'
			RUNNING: 'is still running'

		@core.getJobRun jobName, jobNumber, (err, jobData) ->
			if err
				return msg.send "Oops, couldn't get job data. #{err}"

			msg.send "Job #{jobData.name} #{statusMap[jobData.status]}\n" +
				"url: #{jobData.url}\n" +
				"duration: #{jobData.duration}";
