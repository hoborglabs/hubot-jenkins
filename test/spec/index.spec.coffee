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

	describe 'when asked about job details', ->
		stubGetJobRub = null
		fakeReceive = null

		beforeEach ->
			stubGetJobRub = sinon.stub(jenkins.core, 'getJobRun')
			cb = robot.respond.getCall(1).args[1]
			regexp = robot.respond.getCall(1).args[0]

			fakeReceive = (message) ->
				match = message.match(regexp)
				response =
					send: sinon.spy()
					match: match

				expect(match).not.to.be.null
				return cb response

		it 'should return it by jub run id', ->
			fakeReceive "get job test-job #51"
			fakeReceive "get test-job #51"

			expect(stubGetJobRub.withArgs('test-job', '51')).to.be.calledTwice;

		it 'should return latest stable job when job run is not specified', ->
			fakeReceive "get job test-job"
			fakeReceive "get test-job"

			expect(stubGetJobRub.withArgs('test-job', 'latestStable')).to.be.calledTwice;
