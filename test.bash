#!/bin/bash
set -e
TERM=xterm-256color

hash=$(curl -X GET --header "Accept: */*" "${3}")

hashes=(${hash//,/ })

echo "Hash: $hash"

while :
do
  sleep 20
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
    total_suite_count=$(echo $result | jq '. | length')

    x=0
    pass=true
    while [ $x -le $(( $total_suite_count - 1 )) ]
    do
      echo -e "\n\nTest suite result for $(( $x + 1 )):\n"

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

      # set terminal status based on failed or passed results
      if [ $(echo $result | jq -r ".[$x].failed") -ne 0 ]
      then
        pass=false
      fi

      x=$(( $x + 1 ))
    done

    if [ $pass == true ]; then
      tput setaf 2; echo "All test cases successfully passed."
      exit 0
    fi

    tput setaf 1; echo "One or more test cases failed."
    exit 1
  fi
done
exit
