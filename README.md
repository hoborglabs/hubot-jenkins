# Hubot Jenkins

Hubot script integration with Jenkins.

* trigger job builds
* get job details
* notify rooms on Jenkins events - [Notification plugin](https://wiki.jenkins-ci.org/display/JENKINS/Notification+Plugin)

If you want to get Jenkins notification, configure "Jenkins Events" plugin to POST data to
`/hubot/jenkins-events`




## Development

To test
```
./node_modules/.bin/gulp test
```
