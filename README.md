# Run OpenHistoricalMap

1. Download the submodules: `git submodule update --recursive --remote`
2. If docker-compose isn't already installed, run `bash ./scripts/install_docker.sh` 
3. Bring up the site: 

```bash
docker-compose -f docker-compose.yml -f docker-compose.postgresql.yml build && \
  docker-compose -f docker-compose.yml -f docker-compose.postgresql.yml up
```

If you already have an external PostgreSQL server, set its credentials as
`DATABASE_URL` in `osm-docker.env` and omit `-f
docker-compose.postgresql.yml` from the `docker-compose` commands above.

---

## Setting Up JOSM

1. Download the [JOSM .jar](https://josm.openstreetmap.de/wiki/Download)
2. Once downloaded, doubleclick on the .jar to load it
3. Go to “MainApplication” > “Preferences”
4. Click the second tab down on the left-hand side: “Connection Settings”
5. Change the “OSM Server URL” to: http://www.openhistoricalmap.org/api
6. Under “Authentication” below, switch to “Use Basic Authentication” and enter credentials you just setup in the "OpenStreetMap Website" section above
7. Click “OK”
8. Use JOSM to download data

## Deployment

OpenHistoricalMap uses AWS CodePipeline to deploy services from this
repository to a Fargate cluster running behind an Application Load Balancer
(ALB).

The version of `ohm-website` deployed is controlled by the Git submodule in
`website/openstreetmap-website`. To update it, `git pull` from
`website/openstreetmap-website` and ensure that the current version is what
you expect by using `git show` and clean it using `git checkout .`. Next,
`git add -p website/openstreetmap-website` from the root of
`openhistoricalmap-docker` to update the submodule commit. After pushing to
GitHub, the new version of `ohm-website` will be deployed.

Pushes to the `master` branch on GitHub trigger CodeBuild builds. CGImap and
the website are built according to the buildspecs below, during which they
are pushed to an Elastic Container Registry (ECR). When the build has
completed, CodePipeline uses CodeDeploy to update a Fargate ECS cluster with
updated task definitions pointing to the newly built and published images.
This process takes approximately 25 minutes from `git push` to the cluster
running updated code.

IAM roles generally follow generated conventions for naming and content, with
one exception: CodeBuild service roles require the
"AmazonEC2ContainerRegistryPowerUser" policy in order to push to ECR.

### ECS Task Definitions

These task definitions include references to Parameter Store parameters (part
of AWS Systems Manager) in order to keep certain values (e.g. DB credentials)
encrypted. `secrets` identifies these below.

#### CGImap

```json
{
  "ipcMode": null,
  "executionRoleArn": "arn:aws:iam::<redacted>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "dnsSearchDomains": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/openhistoricalmap",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "entryPoint": null,
      "portMappings": [
        {
          "hostPort": 3000,
          "protocol": "tcp",
          "containerPort": 3000
        }
      ],
      "command": null,
      "linuxParameters": null,
      "cpu": 0,
      "environment": [],
      "resourceRequirements": null,
      "ulimits": null,
      "dnsServers": null,
      "mountPoints": [],
      "workingDirectory": null,
      "secrets": [
        {
          "valueFrom": "POSTGRES_DATABASE",
          "name": "POSTGRES_DATABASE"
        },
        {
          "valueFrom": "POSTGRES_HOST",
          "name": "POSTGRES_HOST"
        },
        {
          "valueFrom": "POSTGRES_PASSWORD",
          "name": "POSTGRES_PASSWORD"
        },
        {
          "valueFrom": "POSTGRES_USER",
          "name": "POSTGRES_USER"
        }
      ],
      "dockerSecurityOptions": null,
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "image": "<redacted>.dkr.ecr.us-east-1.amazonaws.com/cgimap:build-69291910-e696-47de-9833-47acd4e5081a",
      "disableNetworking": null,
      "interactive": null,
      "healthCheck": null,
      "essential": true,
      "links": null,
      "hostname": null,
      "extraHosts": null,
      "pseudoTerminal": null,
      "user": null,
      "readonlyRootFilesystem": false,
      "dockerLabels": null,
      "systemControls": null,
      "privileged": null,
      "name": "cgimap"
    }
  ],
  "placementConstraints": [],
  "memory": "1024",
  "taskRoleArn": null,
  "compatibilities": [
    "EC2",
    "FARGATE"
  ],
  "taskDefinitionArn": "arn:aws:ecs:us-east-1:<redacted>:task-definition/cgimap:5",
  "family": "cgimap",
  "requiresAttributes": [
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.execution-role-ecr-pull"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.task-eni"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.ecr-auth"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.execution-role-awslogs"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.logging-driver.awslogs"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.secrets.ssm.environment-variables"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19"
    }
  ],
  "pidMode": null,
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "networkMode": "awsvpc",
  "cpu": "512",
  "revision": 5,
  "status": "ACTIVE",
  "volumes": []
}
```

### website

```json
{
  "ipcMode": null,
  "executionRoleArn": "arn:aws:iam::<redacted>:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "dnsSearchDomains": null,
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/website",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      },
      "entryPoint": null,
      "portMappings": [
        {
          "hostPort": 3000,
          "protocol": "tcp",
          "containerPort": 3000
        }
      ],
      "command": null,
      "linuxParameters": null,
      "cpu": 0,
      "environment": [
        {
          "name": "OSM_attribution_url",
          "value": "http://www.openhistoricalmap.org/copyright"
        },
        {
          "name": "OSM_copyright_owner",
          "value": "OpenHistoricalMap and contributors"
        },
        {
          "name": "OSM_email_from",
          "value": "OpenHistoricalMap <openhistoricalmap@example.com>"
        },
        {
          "name": "OSM_email_return_path",
          "value": "openhistoricalmap@example.com"
        },
        {
          "name": "OSM_fossgis_osrm_url",
          "value": "//routing.openstreetmap.de/"
        },
        {
          "name": "OSM_generator",
          "value": "OpenHistoricalMap server"
        },
        {
          "name": "OSM_graphhopper_url",
          "value": "//graphhopper.com/api/1/route"
        },
        {
          "name": "OSM_license_url",
          "value": "http://opendatacommons.org/licenses/odbl/1-0/"
        },
        {
          "name": "OSM_nominatim_url",
          "value": "//nominatim.openstreetmap.org/"
        },
        {
          "name": "OSM_overpass_url",
          "value": "//overpass-api.de/api/interpreter"
        },
        {
          "name": "OSM_server_port",
          "value": "3000"
        },
        {
          "name": "OSM_server_protocol",
          "value": "http"
        },
        {
          "name": "OSM_support_email",
          "value": "openhistoricalmap@example.com"
        },
        {
          "name": "RAILS_ENV",
          "value": "production"
        }
      ],
      "resourceRequirements": null,
      "ulimits": null,
      "dnsServers": null,
      "mountPoints": [],
      "workingDirectory": null,
      "secrets": [
        {
          "valueFrom": "DATABASE_URL",
          "name": "DATABASE_URL"
        },
        {
          "valueFrom": "OSM_id_key",
          "name": "OSM_id_key"
        },
        {
          "valueFrom": "OSM_id_secret",
          "name": "OSM_id_secret"
        },
        {
          "valueFrom": "OSM_id_website",
          "name": "OSM_id_website"
        },
        {
          "valueFrom": "OSM_server_url",
          "name": "OSM_server_url"
        },
        {
          "valueFrom": "SECRET_KEY_BASE",
          "name": "SECRET_KEY_BASE"
        }
      ],
      "dockerSecurityOptions": null,
      "memory": null,
      "memoryReservation": null,
      "volumesFrom": [],
      "image": "<redacted>.dkr.ecr.us-east-1.amazonaws.com/website:build-14f1c2f7-ebf3-4c97-8443-80377620a352",
      "disableNetworking": null,
      "interactive": null,
      "healthCheck": null,
      "essential": true,
      "links": null,
      "hostname": null,
      "extraHosts": null,
      "pseudoTerminal": null,
      "user": null,
      "readonlyRootFilesystem": null,
      "dockerLabels": null,
      "systemControls": null,
      "privileged": null,
      "name": "website"
    }
  ],
  "placementConstraints": [],
  "memory": "4096",
  "taskRoleArn": null,
  "compatibilities": [
    "EC2",
    "FARGATE"
  ],
  "taskDefinitionArn": "arn:aws:ecs:us-east-1:<redacted>:task-definition/website:2",
  "family": "website",
  "requiresAttributes": [
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.execution-role-ecr-pull"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.18"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.task-eni"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.ecr-auth"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.execution-role-awslogs"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.logging-driver.awslogs"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "ecs.capability.secrets.ssm.environment-variables"
    },
    {
      "targetId": null,
      "targetType": null,
      "value": null,
      "name": "com.amazonaws.ecs.capability.docker-remote-api.1.19"
    }
  ],
  "pidMode": null,
  "requiresCompatibilities": [
    "FARGATE"
  ],
  "networkMode": "awsvpc",
  "cpu": "2048",
  "revision": 2,
  "status": "ACTIVE",
  "volumes": []
}
```

### AWS CodeBuild Buildspecs

#### CGImap

```yaml
version: 0.2

env:
  variables:
    REPOSITORY_URI: <redacted>.dkr.ecr.us-east-1.amazonaws.com/cgimap

phases:
  install:
    commands:
      # re-clone to pick up git metadata
      - git clone https://github.com/openhistoricalmap/openhistoricalmap-docker ohm-docker
      # check out the target version
      - cd ohm-docker && git checkout $CODEBUILD_RESOLVED_SOURCE_VERSION && cd -
      # test to see if anything CGImap-related was touched (this doesn't work
      # because the push may have included more than 1 commit)
      # - grep -q cgimap/ <<< $(cd ohm-docker && git diff --name-only @~ @)
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=build-$(echo $CODEBUILD_BUILD_ID | awk -F":" '{print $2}')
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:latest ohm-docker/cgimap/
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo "[{\"name\":\"cgimap\",\"imageUri\":\"${REPOSITORY_URI}:${IMAGE_TAG}\"}]" | tee imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
```

#### website

```yaml
version: 0.2

env:
  variables:
    REPOSITORY_URI: <redacted>.dkr.ecr.us-east-1.amazonaws.com/website

phases:
  install:
    commands:
      # re-clone to pick up git submodules
      - git clone --recursive https://github.com/openhistoricalmap/openhistoricalmap-docker ohm-docker
      # check out the target version
      - cd ohm-docker && git checkout $CODEBUILD_RESOLVED_SOURCE_VERSION && cd -
      # test to see if anything website-related was touched (this doesn't work
      # because the push may have included more than 1 commit)
      # - grep -q website/ <<< $(cd ohm-docker && git diff --name-only @~ @)
  pre_build:
    commands:
      - echo Logging in to Amazon ECR...
      - aws --version
      - $(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
      - COMMIT_HASH=$(echo $CODEBUILD_RESOLVED_SOURCE_VERSION | cut -c 1-7)
      - IMAGE_TAG=build-$(echo $CODEBUILD_BUILD_ID | awk -F":" '{print $2}')
  build:
    commands:
      - echo Build started on `date`
      - echo Building the Docker image...
      - docker build -t $REPOSITORY_URI:latest ohm-docker/website/
      - docker tag $REPOSITORY_URI:latest $REPOSITORY_URI:$IMAGE_TAG
  post_build:
    commands:
      - echo Build completed on `date`
      - echo Pushing the Docker images...
      - docker push $REPOSITORY_URI:latest
      - docker push $REPOSITORY_URI:$IMAGE_TAG
      - echo "[{\"name\":\"website\",\"imageUri\":\"${REPOSITORY_URI}:${IMAGE_TAG}\"}]" | tee imagedefinitions.json
artifacts:
  files:
    - imagedefinitions.json
```