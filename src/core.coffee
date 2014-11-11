url = require('url')
querystring = require('querystring')
_ = require 'lodash'

module.exports.create = (http, config) ->
	new Jenkins http, config

class Jenkins
	constructor: (http, config) ->
		@http = http
		@config = @_loadConfig config

	announceJenkinsEvent: (data, cb) ->
		unless @config.jobs[data.name]
			return cb ''

		phaseFound = false
		if data.build.phase in @config.jobs[data.name].jenkins.phases
			phaseFound = true

		if 'all' in @config.jobs[data.name].jenkins.phases
			phaseFound = true

		unless phaseFound
			return cb ''

		if 'STARTED' == data.build.phase
			return cb "Jenkins job #{data.name} started. #{data.build.full_url}"

		if 'FINALIZED' == data.build.phase
			statusMap = {
				SUCCESS: 'successful'
			};

			return cb "Jenkins job #{data.name} finished #{statusMap[data.build.status]}. #{data.build.full_url}"

		if 'COMPLETED' == data.build.phase
			return cb "Jenkins job #{data.name} completed. #{data.build.full_url}"

		cb ""

	notifyJenkinsAboutPullRequest: (data, robot, cb) ->
		if data.action != 'opened'
			cb "Pull request ##{data.number} updated"

		pr = data.pull_request
		repoCfg = @config.repos[pr.base.repo.full_name]

		for job in repoCfg.jobs
			this._buildPullRequest job.jenkins.job, pr, cb

	build: (jobName, buildParams, cb) ->
		unless @config.jobs[jobName]
			return cb "Unknown job #{jobName}", null

		build = 'build'

		if Object.keys(buildParams).length > 0
			build = 'buildWithParameters'

		buildParams['token'] = @config.token if @config.token
		url = "#{@config.url}/job/#{jobName}/#{build}"
		extras = _.map buildParams, (val, key) -> key + "=" + val
		url += "?#{extras.join('&')}"

		@http(url)
			.post() (err, res, body) =>
				if err
					return cb err, null

				queue = res.headers.location
				@_checkQueue queue, cb

	rebuild: (jobName, cb) ->
		cb("not implemented yet", null)

	getJobRun: (jobName, id, cb) ->
		@_getJsonApi "#{@config.url}/job/#{jobName}/#{id}/", cb

	_buildPullRequest: (job, pr, cb) ->
		@build(job, {
			cause: "Pull+Request+#{pr.number}"
			GIT_SHA: pr.head.sha
			GIT_PR: pr.number
		}, () ->
			if err
				cb "Encountered an error :( #{err}"
				return

			cb "Jenkins Notified - building #{job} for PR##{pr.number} (#{pr.head.ref})";
		)

	_loadConfig: (config) ->
		cfg = _.merge {}, config.jenkins
		jobs = {}
		repos = {}

		for job in config.jobs
			jobs[job.jenkins.job] = job if job.jenkins
			if job.github
				if !repos[job.github.name]
					repos[job.github.name] = { jobs: [] }
				repos[job.github.name].jobs.push(job)

		cfg.jobs = jobs
		cfg.repos = repos

		cfg

	_checkQueue: (queueUrl, cb) ->
		@_getJsonApi queueUrl, (err, data) =>
			if err
				return cb err, null

			@_getJsonApi data.executable.url, cb

	_getJsonApi: (url, cb) ->
		url = url.replace(/\/?$/, '') + "/api/json"

		@http(url)
			.get() (err, res, body) =>
				if err
					return cb err, null

				data = JSON.parse body
				if !data
					return cb "Can't parse response as JSON - #{body}", null

				cb null, data
