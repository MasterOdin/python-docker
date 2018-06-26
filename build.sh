## Docker configuration details
USERNAME=masterodin
IMAGE=python

echo "Local:"
echo "    Python: ${PYTHON_VERSION}"
echo "    Pip   : ${PYPI_VERSION}"
echo ""

IMAGE_NAME="${USERNAME}/${IMAGE}:${TRAVIS_PYTHON_VERSION}"
docker pull ${IMAGE_NAME}
set -ex
if [ $? -eq 0 ]; then
  # check python and pip version
  PY_VERSION=$(docker run masterodin/python:3.6 python --version | grep -o "[0-9]\{1,2\}.[0-9]\{1,2\}.[0-9]\{1,2\}")
  PYPI_VERSION=$(docker run ${IMAGE_NAME} pip --version | grep -o "[0-9]\{1,2\}.[0-9]\{1,2\}.[0-9]\{1,2\}" | head -1)
  echo "Docker:"
  echo "    Python: ${PY_VERSION}"
  echo "    Pip   : ${PYPI_VERSION}"

  if [ "${PY_VERSION}" = "${PYTHON_VERSION}"] && [ "${PYPI_VERSION}" = "${PYTHON_PIP_VERSION}" ]; then
    echo "Docker and Local versions match. Doing nothing."
    exit 0
  fi
else
  run_build=true
fi

if [ "${run_build}" = true ]; then
  set -ex
  docker build -t ${IMAGE_NAME} --build-arg PYTHON_VERSION="${PYTHON_VERSION}" --build-arg PYTHON_PIP_VERSION="${PYTHON_PIP_VERSION}" .
  docker push ${IMAGE_NAME}
fi