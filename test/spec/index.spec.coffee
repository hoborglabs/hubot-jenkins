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
			respond: sinon.spy()
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

			jenkins.core.announceJenkinsEvent = sinon.stub()
					.callsArgWith(1, 'Jenkins Event callback')

			# post jenkins notification
			robot.router.post.getCall(0).callArgWith(1, req, res);

		it 'should notify room about jenkins job result', ->
			expect(robot.messageRoom).to.be.calledWith('testRoom', 'Jenkins Event callback');

		it 'should notify Jenkins and Github objects', ->
			expect(jenkins.core.announceJenkinsEvent).to.be.called
			# expect(ciOperator.github.updatePullRequestStatus).to.be.called
