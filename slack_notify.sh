#!/bin/bash
# Slack Notification Script for GitLab CI/CD
# Usage:
#   For "Pipeline Started":  ./slack_notify.sh start "$COMMIT_ID"
#   For stage completions:   ./slack_notify.sh complete
### https://lowhangingfruit.gitlab.io/mkdocstemplate/maintainer-info/emoji/ #### for emojis of slack like rocket

# Get notification type and commit ID
NOTIFICATION_TYPE=$1
GH_COMMIT_ID=$2

# Determine environment based on branch name
if [[ "$CI_COMMIT_REF_NAME" == "main" ]]; then
  ENVIRONMENT="Production"
elif [[ "$CI_COMMIT_REF_NAME" == "qa" ]]; then
  ENVIRONMENT="QA"
elif [[ "$CI_COMMIT_REF_NAME" == "dev" ]]; then
  ENVIRONMENT="Development"
else
  ENVIRONMENT="Custom ($CI_COMMIT_REF_NAME)"
fi

# Get current stage name from variables or fallback to CI_JOB_STAGE
CURRENT_STAGE=${STAGE_NAME:-$CI_JOB_STAGE}

# "Pipeline Started" notification (with commit ID)
if [ "$NOTIFICATION_TYPE" == "start" ]; then
  curl -X POST -H "Content-type: application/json" --data "{
    \"text\":\"Pipeline Started\",
    \"blocks\":[{
      \"type\":\"section\",
      \"text\":{
        \"type\":\"mrkdwn\",
        \"text\":\"*:rocket: Pipeline Started!*\\n*Project:* $CI_PROJECT_NAME\\n*Pipeline ID:* $CI_PIPELINE_ID\\n*Commit ID:* $GH_COMMIT_ID\\n*Branch:* $CI_COMMIT_REF_NAME\\n*Environment:* $ENVIRONMENT\\n*Triggered by:* $GITLAB_USER_NAME\\n*Repository:* $CI_PROJECT_NAME\\n*Pipeline URL:* <$CI_PIPELINE_URL|View Pipeline>\"
      },
      \"accessory\":{
        \"type\":\"image\",
        \"image_url\":\"https://about.gitlab.com/images/press/logo/png/gitlab-icon-rgb.png\",
        \"alt_text\":\"GitLab Logo\"
      }
    }]
  }" $SLACK_WEBHOOK

# Stage/Pipeline completion notification
elif [ "$NOTIFICATION_TYPE" == "complete" ]; then
  # Set timezone
  export TZ="Asia/Riyadh"
  DEPLOYMENT_DATE=$(date +"%Y-%m-%dT%H:%M:%S AST")

  # Get app version if available
  VERSION=$(jq -r .version package.json 2>/dev/null || echo "unknown")

  # UPPERCASE job status
  CI_JOB_STATUS_UPPER=${CI_JOB_STATUS^^}

  # Success/failure emoji and title
  if [ "$CI_JOB_STATUS" == "success" ]; then
    EMOJI_STATUS=":white_check_mark:"
    STATUS_TEXT="Succeeded"
  else
    EMOJI_STATUS=":alert:"
    STATUS_TEXT="Failed"
  fi

  # Decide if final stage or not
  if [ "$CURRENT_STAGE" == "deploy" ] && [ "$CI_JOB_STATUS" == "success" ]; then
    MESSAGE_TITLE="Pipeline Completed! :done:"
  else
    MESSAGE_TITLE=":rocket: Deployment Stage $CURRENT_STAGE $STATUS_TEXT $EMOJI_STATUS"
  fi

  # Send stage/pipeline completion notification
  curl -X POST -H "Content-type: application/json" \
  --data "{
    \"text\":\"$MESSAGE_TITLE\",
    \"blocks\":[{
      \"type\":\"section\",
      \"text\":{
        \"type\":\"mrkdwn\",
        \"text\":\"*$MESSAGE_TITLE*\\n*:hash:Pipeline ID:* $CI_PIPELINE_ID\\n*:file_folder:Project:* $CI_PROJECT_NAME\\n*:cloud:Repository:* $CI_PROJECT_NAME\\n*:computer:Environment:* $ENVIRONMENT\\n*:hourglass:Job:* $CI_JOB_NAME\\n*:arrows_counterclockwise:Stage:* $CURRENT_STAGE\\n*::bust_in_silhouette:User:* $GITLAB_USER_NAME\\n*:date:Deployment Date:* $DEPLOYMENT_DATE\\n*:loudspeaker:Status:* $CI_JOB_STATUS_UPPER $EMOJI_STATUS\\n*:exclamation:Details:* <$CI_JOB_URL|Job Details>\"
      },
      \"accessory\":{
        \"type\":\"image\",
        \"image_url\":\"https://about.gitlab.com/images/press/logo/png/gitlab-icon-rgb.png\",
        \"alt_text\":\"GitLab Logo\"
      }
    }]
  }" $SLACK_WEBHOOK
fi
