# Endtest GitHub Run Tests Deployment Action

The repository is for GitHub Actions which runs test cases of [Endtest](https://endtest.io) with specified label.

### Example workflow:

```
on: [push]

name: endtest

jobs:
  endtest:
    name: Endtest runner
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2

      - name: Checkout endtest actions repo
        uses: actions/checkout@v2
        with:
          repository: namespace-team/endtest-github-actions
          token: ${{ secrets.ENDTEST_REPO_ACCESS_TOKEN }}
          ref: refs/tags/v1.0.0

      - name: Run Endtest functional tests
        id: endtest_functional_tests
        uses: ./
        with:
          app_id: ${{ secrets.ENDTEST_APP_ID }}
          app_code: ${{ secrets.ENDTEST_APP_CODE }}
          api_request: ${{ secrets.ENDTEST_API_REQUEST }}
```

### Environment variables

- `ENDTEST_REPO_ACCESS_TOKEN` {string} - The token which clone access to this repo.

### Inputs

- `app_id` {string} - The App ID for your Endtest account ([available here](https://endtest.io/settings)).
- `app_code` {string} - The App Code for your Endtest account ([available here](https://endtest.io/settings)).
- `api_request` {string} - The Endtest API request.


### Outputs:

* `test_suite_name` {string} - The name of the test suite.
* `configuration` {string} - The configuration of the machine or mobile device on which the test was executed.
* `test_cases` {int32} - The number of test cases.
* `passed` {int32} - The number of assertions that have passed.
* `failed` {int32} - The number of assertions that have failed.
* `errors` {int32} - The number of errors that have been encountered.
* `start_time` {timestamp} - The timestamp for the start of the test execution.
* `end_time` {timestamp} - The timestamp for the end of the test execution.
* `detailed_logs` {string} - The detailed logs for the test execution.
* `screenshots_and_video` {string} - The URLs for the screenshots and the video recording of the test execution.
* `hash` {string} - The unique hash for the test execution.
* `results` {string} - The link to the Results page for the test execution.
