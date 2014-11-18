#!/bin/bash

function main {
	# getopt('j:s:p:')

	JOB='test-job'
	STATUS='SUCCESS'
	PHASE='FINALIZED'
	URL='http://127.0.0.1:8080'

	while getopts j:s:p:u:h opt; do
		case "$opt" in
			j)
				JOB="$OPTARG"
				;;

			s)
				STATUS="$OPTARG"
				;;

			p) PHASE="$OPTARG"
				;;

			u)
				UR="$OPTARG"
				;;

			h)
				usage
				;;

			"")
				usage "Missing arguments";
				;;

			*)
				usage "Unrecognied option '$opt'";
				;;
		esac
	done;

	sendNotification "$JOB" "$STATUS" "$PHASE" "$URL"
	return 0
}

function sendNotification {
	JOB=$1
	STATUS=$2
	PHASE=$3
	URL=$4

	cat test/fixtures/jenkins_notification.tpl.json\
		| sed "s/{{JOBNAME}}/$JOB/g"\
		| sed "s/{{PHASE}}/$PHASE/g"\
		| sed "s/{{STATUS}}/$STATUS/g"\
	| curl --data @- -H "Content-Type: application/json" $URL/hubot/jenkins-events
}

function usage() {
	msg=$1
	if [[ $msg ]]; then
		logMsg "$msg"
	fi

	echo "jenkins-notification -j job-name -s job_status -p job_phase

-j 'job_name'   Jenkins job name
-s 'job_status' Job status - use one from SUCCESS, FAILED, ABORTED,
-p 'job_phase'  Job phase, please use one of: STARTED, FINALIZED or COMPLETED
-h              Displays this message
	"
	exit 1;
}

function logMsg {
	msg=$1
	echo "  ${msg}"
}

main "$@"
exit $?
