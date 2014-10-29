_ = require 'lodash'
chai = require('chai');
sinon = require('sinon');
expect = chai.expect;
jenkinsCreator = require('../../src/index')

chai.use(require('sinon-chai'));

describe 'Jenkins Hubot plugin', ->
	robot = null
	jenkins = null

	process.env.HUBOT_CIOPERATOR_CONFIG = __dirname + "/../test_config.json"

	beforeEach ->
		testCfg = _.merge {}, require(process.env.HUBOT_CIOPERATOR_CONFIG);

		robot =
			respond: sinon.stub()
			hear: sinon.spy()
			router: {
				post: sinon.stub()
			},
			messageRoom: sinon.spy()

		jenkins = jenkinsCreator(robot);

	it 'should listen for jenkins notification messages', ->
		expect(robot.router.post).to.have.been.calledWith('/hubot/jenkins-events')

	describe 'on jenkins notification', ->
		beforeEach ->
			req =
				url: '/hubot/jenkins-webhook?room=testRoom'
				body: _.merge {}, require('../fixtures/jenkins_notification.json')
			res =
				end: sinon.stub()

			sinon.stub(jenkins.core, 'announceJenkinsEvent')
				.callsArgWith(1, 'Jenkins Event callback')

			# post jenkins notification
			robot.router.post.getCall(0).callArgWith(1, req, res);

		it 'should notify room about jenkins job result', ->
			expect(robot.messageRoom).to.be.calledWith('testRoom', 'Jenkins Event callback');

		it 'should notify Jenkins and Github objects', ->
			expect(jenkins.core.announceJenkinsEvent).to.be.called
			# expect(ciOperator.github.updatePullRequestStatus).to.be.called

	describe 'when asked...', ->
		fakeReceive = null

		setupFakeReceive = (respondIndex) ->
			cb = robot.respond.getCall(respondIndex).args[1]
			regexp = robot.respond.getCall(respondIndex).args[0]

			fakeReceive = (message) ->
				match = message.match(regexp)
				response =
					send: sinon.spy()
					match: match

				expect(match).not.to.be.null
				return cb response

		describe 'about job details', ->
			stubGetJobRub = null

			beforeEach ->
				setupFakeReceive(0)
				stubGetJobRub = sinon.stub(jenkins.core, 'getJobRun')

			it 'should return it by jub run id', ->
				fakeReceive "get job test-job #51"
				fakeReceive "get test-job #51"
				fakeReceive "get test-job #51"

				expect(stubGetJobRub.withArgs('test-job', '51')).to.be.called

			it 'should return latest stable job when job run is not specified', ->
				fakeReceive "get job test-job"
				fakeReceive "get test-job"

				expect(stubGetJobRub.withArgs('test-job', 'latestStable')).to.be.calledTwice

		describe 'to build a job', ->
			stubBuild = null

			beforeEach ->
				setupFakeReceive(1)
				stubBuild = sinon.stub(jenkins.core, 'build')

			it 'should build a job', ->
				fakeReceive "build job test-job-dev"
				fakeReceive "build test-job-dev"

				expect(stubBuild.withArgs('test-job-dev')).to.be.calledTwice

			it 'should run a job', ->
				fakeReceive "run job test-job-dev"
				fakeReceive "run test-job-dev"

				expect(stubBuild.withArgs('test-job-dev')).to.be.calledTwice

		describe 'to rebuild a job', ->
			stubRebuild = null

			beforeEach ->
				setupFakeReceive(2)
				stubRebuild = sinon.stub(jenkins.core, 'rebuild')

			it 'should rebuild a job', ->
				fakeReceive "rebuild job test-job-dev"
				fakeReceive "rebuild test-job-dev"

				expect(stubRebuild.withArgs('test-job-dev')).to.be.calledTwice

			it 'should rerun a job', ->
				fakeReceive "rerun job test-job-dev"
				fakeReceive "rerun test-job-dev"

				expect(stubRebuild.withArgs('test-job-dev')).to.be.calledTwice
