## Docker configuration details
USERNAME=masterodin
IMAGE=python

run_build=false
docker pull masterodin/python:${TRAVIS_PYTHON_VERSION}
if [ $? -eq 0 ]; then
  # check python and pip version
  echo "need to check"
else
  run_build=true
fi

if [ "${run_build}" = true ]; then
  set -ex
  docker build -t ${USERNAME}/${IMAGE}:${TRAVIS_PYTHON_VERSION} --build-arg PYTHON_VERSION="${PYTHON_VERSION}" --build-arg PYTHON_PIP_VERSION="${PYTHON_PIP_VERSION}" .
  docker push ${USERNAME}/${IMAGE}:${TRAVIS_PYTHON_VERSION}
fi