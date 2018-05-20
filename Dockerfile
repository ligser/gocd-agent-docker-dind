# Copyright 2017 ThoughtWorks, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

###############################################################################################
# This file is autogenerated by the repository at https://github.com/gocd/docker-gocd-agent.
# Please file any issues or PRs at https://github.com/gocd/docker-gocd-agent
###############################################################################################

FROM docker:dind
MAINTAINER GoCD <go-cd-dev@googlegroups.com>

LABEL gocd.version="18.5.0" \
  description="GoCD agent based on docker version dind" \
  maintainer="GoCD <go-cd-dev@googlegroups.com>" \
  gocd.full.version="18.5.0-6679" \
  gocd.git.sha="a54c3fd44ef9ccbab1b0d856a8d735929eab97f7"

# force encoding
ENV LANG=en_US.utf8

ARG UID=1000
ARG GID=1000

RUN \
# add our user and group first to make sure their IDs get assigned consistently,
# regardless of whatever dependencies get added
  addgroup -g ${GID} go && \ 
  adduser -D -u ${UID} -s /bin/bash -G go go && \ 
  addgroup go root && \
  apk --no-cache upgrade && \
  apk add --no-cache openjdk8-jre-base git mercurial subversion openssh-client bash curl supervisor && \
# download the zip file
  curl --fail --location --silent --show-error "https://download.gocd.org/binaries/18.5.0-6679/generic/go-agent-18.5.0-6679.zip" > /tmp/go-agent.zip && \
# unzip the zip file into /go-agent, after stripping the first path prefix
  unzip /tmp/go-agent.zip -d / && \
  mv go-agent-18.5.0 /go-agent && \
  rm /tmp/go-agent.zip && \
  mkdir -p /docker-entrypoint.d && \
  mkdir -p /var/log/docker && \
  mkdir -p /var/log/go-agent

# ensure that logs are printed to console output
COPY agent-bootstrapper-logback-include.xml /go-agent/config/agent-bootstrapper-logback-include.xml
COPY agent-launcher-logback-include.xml /go-agent/config/agent-launcher-logback-include.xml
COPY agent-logback-include.xml /go-agent/config/agent-logback-include.xml

ADD go.conf /etc/supervisor/conf.d/
ADD supervisor.conf /etc/supervisor/supervisor.conf
ADD init.sh /
RUN chmod +x /init.sh

ENTRYPOINT ["/init.sh"]
