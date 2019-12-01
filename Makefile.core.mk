# Copyright Istio Authors
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

lint: lint-all

lint-buildifier:
	@bazel run //:buildifier -- -showlog -mode=check $(git ls-files| grep -e BUILD -e WORKSPACE | grep -v vendor)

format: format-go
	go mod tidy

test:
	@go test -race ./...

gen: generate-config

gen-check: gen check-clean-repo

.PHONY: testgrid
testgrid:
	@GOARCH=amd64 GOOS=linux go get k8s.io/test-infra/testgrid/cmd/configurator@d5d7ce3eb0ffe35c899fe9358586cdffb6525899
	@GOARCH=amd64 GOOS=linux go run k8s.io/test-infra/testgrid/cmd/configurator --prow-config prow/config.yaml --prow-job-config prow/cluster/jobs --output-yaml --yaml testgrid/default.yaml --oneshot --output testgrid/istio.gen.yaml

generate-config:
	@rm -fr prow/cluster/jobs/istio/*/*.gen.yaml
	@(cd prow/config/cmd; GOARCH=amd64 GOOS=linux go run generate.go write)

diff-config:
	@(cd prow/config/cmd; GOARCH=amd64 GOOS=linux go run generate.go diff)

check-config:
	@(cd prow/config/cmd; GOARCH=amd64 GOOS=linux go run generate.go check)

include common/Makefile.common.mk
