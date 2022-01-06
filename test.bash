#!/bin/bash
set -e

hash=$(curl -X GET --header "Accept: */*" "${3}")

hashes=(${hash//,/ })

echo "Hash: $hash"

while :
do
  sleep 5
  result=$(curl -X GET --header "Accept: */*" "https://endtest.io/api.php?action=getResults&appId={$1}&appCode=${2}&hash=${hash}&format=json")

  if [ $(echo $result | jq 'map(select(. == "Test is still running.")) | length') -gt 0 ]
  then
    status=$result
    # Don't print anything
    echo "Test is still running."
  elif [ $(echo $result | jq 'map(select(. == "Processing video recording.")) | length') -gt 0 ]
  then
    status=$result
    # Don't print anything
    echo "Processing video recording"
  elif [ $(echo $result | jq 'map(select(. == "Stopping.")) | length') -gt 0 ]
  then
    status=$result
    echo "Stopping."
  elif [ $(echo $result | jq 'map(select(. == "Erred.")) | length') -gt 0 ]
  then
    status=$result
    echo "Erred."
  elif [ "$result" == "" ]
  then
    status=$result
    echo "empty result"
    # Don't print anything
  else
    echo -e "\n\n\n\n\nPASSED\n\n\n\n"
    echo -e "\n\n\n\n\nFirst execution completed\n\n\n"

    total_suite_count=$(echo $result | jq '. | length')

    x=0
    while [ $x -le $(( $total_suite_count - 1 )) ]
    do
      echo $x

      testsuitename=$( echo $result | jq ".[$x].test_suite_name" )
      configuration=$( echo $result | jq ".[$x].configuration" )
      testcases=$( echo $result | jq ".[$x].test_cases" )
      passed=$( echo $result | jq ".[$x].passed" )
      failed=$( echo $result | jq ".[$x].failed" )
      errors=$( echo $result | jq ".[$x].errors" )
      detailedlogs=$( echo $result | jq ".[$x].detailed_logs" )
      screenshotsandvideo=$( echo $result | jq ".[$x].screenshots_and_video" )
      starttime=$( echo $result | jq ".[$x].start_time" )
      endtime=$( echo $result | jq ".[$x].end_time" )

      suite_hash=${hashes[$x]}
      results=https://endtest.io/results?hash="$suite_hash"

      echo Test Suite Name: $testsuitename
      echo Configuration: $configuration
      echo Test Cases: $testcases
      echo Passed: $passed
      echo Failed: $failed
      echo Errors: $errors
      echo Start Time: $starttime
      echo End Time: $endtime
      echo Hash: $suite_hash
      echo Results: $results

      echo ::set-output name=test_suite_name::$( echo $testsuitename )
      echo ::set-output name=configuration::$( echo $configuration )
      echo ::set-output name=test_cases::$( echo $testcases )
      echo ::set-output name=passed::$( echo $passed )
      echo ::set-output name=failed::$( echo $failed )
      echo ::set-output name=errors::$( echo $errors )
      echo ::set-output name=start_time::$( echo $starttime )
      echo ::set-output name=end_time::$( echo $endtime )
      # echo ::set-output name=detailed_logs::$( echo $detailedlogs )
      echo ::set-output name=screenshots_and_video::$( echo $screenshotsandvideo )
      echo ::set-output name=hash::$( echo $hash )
      echo ::set-output name=results::$( echo $results )

      echo -e "\n\n"

      x=$(( $x + 1 ))
    done
    exit 0
  fi
done
exit
