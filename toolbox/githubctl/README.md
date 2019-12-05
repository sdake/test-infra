# GitHub Control

## Triggering Release Qualification

This file triggers release qualification in the latest release pipeline (and automates 0.2.* releases, more information can be found [here](https://github.com/istio/istio/blob/master/release/README.md)).
It is a tool of our own that acts as a GitHub client making REST calls through the GitHub API.

You will need a ```<github token file>``` text file containing the github peronal access token setup following the [instruction](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line/)

```bash
$ git clone https://github.com/istio/test-infra.git
```

and build it using

```bash
$ bazel build //toolbox/githubctl
```

The binary output is located in bazel-bin/toolbox/githubctl/linux_amd64_stripped/githubctl.

```bash
$ alias githubctl="${PWD}/bazel-bin/toolbox/githubctl/linux_amd64_stripped/githubctl"
```

To trigger daily release qualification,

```bash
$ githubctl --token_file=<github token file> \
    --op=dailyRelQual \
    --hub=<hub of remote docker image registry> \
    --tag=<tag of the release candidate> \
    --gcsPath=<GCS path where istioctl is stored>
```

## Get Latest Green SHA

A green SHA is a commit sha that has passed all post submit checks. `githubctl` can also be used to get the latest green SHA of branch in a repo.

```bash
$ export GREEN_SHA=$(githubctl --token_file=<github token file> \
    --op=getLatestGreenSHA \
    --repo=istio \
    --base_branch=master \
    --logtostderr)
```

Logs are output to stderr and only the latest green sha is directed to stdout.

When using `githubctl` for this purpose, additional configuration such as `--max_commit_depth`, `--max_run_depth`, and `--maxConcurrentRequests` is available for customization.

If some postsubmit jobs have been failing consistently and one wishes to ignore these jobs when searching for the latest green sha, use `--skip` which takes a comma separated list of job names. For example, `--skip=istio-pilot-e2e-envoyv2-v1alpha3-k8s-1.10,e2e-simpleTests`.

To see more verbose logging information, use `-v=1` as githubctl uses V-style logging.
