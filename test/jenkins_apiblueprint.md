
# GET /job/test-job/api/json
* Response 200 (application/json)
  {
    "actions":[
      {
        "parameterDefinitions":[
          {
            "defaultParameterValue":{
              "value":""
            },
            "description":"Git SHA ",
            "name":"GIT_SHA",
            "type":"StringParameterDefinition"
          }
        ]
      }
    ],
    "description":"",
    "displayName":"test job",
    "displayNameOrNull":null,
    "name":"test-job",
    "url":"http://127.0.0.1:3000/job/test-job/",
    "buildable":true,
    "builds":[
      {
        "number":51,
        "url":"http://127.0.0.1:3000/job/test-job/51/"
      },
      {
        "number":50,
        "url":"http://127.0.0.1:3000/job/test-job/50/"
      },
      {
        "number":49,
        "url":"http://127.0.0.1:3000/job/test-job/49/"
      }
    ],
    "color":"blue",
    "firstBuild":{
      "number":1,
      "url":"http://127.0.0.1:3000/job/test-job/1/"
    },
  "healthReport":[
    {
      "description":"Build stability: No recent builds failed.",
      "iconUrl":"health-80plus.png",
      "score":100
    }
  ],
    "inQueue":false,
  "keepDependencies":false,
    "lastBuild":{
      "number":51,
      "url":"http://127.0.0.1:3000/job/test-job/51/"
    },
    "lastCompletedBuild":{
      "number":51,
      "url":"http://127.0.0.1:3000/job/test-job/51/"
    },
    "lastFailedBuild":null,
    "lastStableBuild":{
      "number":51,
      "url":"http://127.0.0.1:3000/job/test-job/51/"
    },
    "lastSuccessfulBuild":{
      "number":51,
      "url":"http://127.0.0.1:3000/job/test-job/51/"
    },
    "lastUnstableBuild":null,
    "lastUnsuccessfulBuild":null,
    "nextBuildNumber":52,
    "property":[
      { },
      { },
      {
        "parameterDefinitions":[
          {
            "defaultParameterValue":{
              "name":"GIT_SHA",
              "value":""
            },
            "description":"Git SHA ",
            "name":"GIT_SHA",
            "type":"StringParameterDefinition"
          }
        ]
      }
    ],
    "queueItem":null,
    "concurrentBuild":false,
    "downstreamProjects": [ ],
    "scm":{},
    "upstreamProjects": [ ]
  }

# GET /job/test-job/{id}/api/json
* Response 200 (application/json)
{
  "actions":[
    {
      "parameters":[
        {
          "name":"GIT_SHA",
          "value":""
        }
      ]
    },
    {
      "causes":[
        {
          "shortDescription":"Started by remote host 192.168.1.22"
        }
      ]
    },
    {

    }
  ],
  "artifacts":[

  ],
  "building":false,
  "description":null,
  "duration":5134,
  "estimatedDuration":5260,
  "executor":null,
  "fullDisplayName":"test-job #51",
  "id":"2014-10-25_13-23-33",
  "keepLog":false,
  "number":51,
  "result":"SUCCESS",
  "timestamp":1414243413000,
  "url":"http://ci01.hoborglabs.com/jenkins/job/test-job/51/",
  "builtOn":"",
  "changeSet":{
    "items":[

    ],
    "kind":null
  },
  "culprits":[

  ]
}

# GET /job/test-job/lastBuild/api/json
* Response 200 (application/json)
{
  "actions":[
    {
      "parameters":[
        {
          "name":"GIT_SHA",
          "value":""
        }
      ]
    },
    {
      "causes":[
        {
          "shortDescription":"Started by remote host 192.168.1.22"
        }
      ]
    },
    {

    }
  ],
  "artifacts":[

  ],
  "building":false,
  "description":null,
  "duration":5134,
  "estimatedDuration":5260,
  "executor":null,
  "fullDisplayName":"test-job #51",
  "id":"2014-10-25_13-23-33",
  "keepLog":false,
  "number":51,
  "result":"SUCCESS",
  "timestamp":1414243413000,
  "url":"http://ci01.hoborglabs.com/jenkins/job/test-job/51/",
  "builtOn":"",
  "changeSet":{
    "items":[

    ],
    "kind":null
  },
  "culprits":[

  ]
}


# POST /job/test-job/buildWithParameters{?token}
* Response 200 (text/text)
* Headers
    location: http://127.0.0.1:3000/queue/item/10

# POST /job/test-job/build{?token}
* Response 200 (text/text)
* Headers
    location: http://127.0.0.1:3000/queue/item/10

# GET /queue/item/{id}/api/json
* Response 200 (application/json)
{
  "actions":[
    {
      "causes":[
        {
          "shortDescription":"Started by remote host 192.168.1.22"
        }
      ]
    }
  ],
  "blocked":false,
  "buildable":false,
  "id":6,
  "inQueueSince":1415495619684,
  "params":"",
  "stuck":false,
  "task":{
    "name":"test-job",
    "url":"http://127.0.0.1:3000/job/test-job/",
    "color":"blue"
  },
  "url":"queue/item/6/",
  "why":null,
  "cancelled":false,
  "executable":{
    "number":6,
    "url":"http://127.0.0.1:3000/job/test-job/6/"
  }
}
