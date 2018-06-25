# python-docker

While Docker provides an official python repository, the versions of python built against Debian are against different versions (3.7 uses only Stretch, 3.6 can use either Stretch or Jessie, 3.4 and 3.5 use only Jessie, etc.) which means that pulling in dependencies results in different versions of things which in turn can affect packages and testing them. This repository aims to correct that by aiming to provide a range of python versions against the same Debian OS (stable-slim).

Additionally, I'd like to have these images to be updated to newer versions of python without requiring any direct
intervention on my part, beyond occassionally updating a .travis.yml file with new Python versions to care about
(which should be largely rare). The way this then works is that Travis-CI is activated to utilize a CRON job that runs
weekly. It then pulls in the the previously built docker image (assuming it exists), and then checks what version of
Python and pip were used. If they match the most known up-to-date versions, do nothing, else, we build our dockerfile
with the latest values and then push that new image to the Docker Hub.

The Dockerfile is based off the 
[python:3.6-stretch-slim Dockerfile](https://github.com/docker-library/python/blob/b8c94a31a98a535477200482a32c95192f85af5b/3.6/stretch/slim/Dockerfile) 
from the [docker-library/python repo](https://github.com/docker-library/python) with some tweaks to enable it to be
purely automated and rely upon Travis-CI to push new versions as necessary.