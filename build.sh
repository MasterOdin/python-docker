## Docker configuration details
USERNAME=masterodin
IMAGE=python

echo "Local:"
echo "    Python: ${PYTHON_VERSION}"
echo "    Pip   : ${PYTHON_PIP_VERSION}"
echo ""

IMAGE_NAME="${USERNAME}/${IMAGE}:${TRAVIS_PYTHON_VERSION}"
docker pull ${IMAGE_NAME} > /dev/null 2>&1
LAST=$?
set -e
if [ "${LAST}" -eq 0 ]; then
  # check python and pip version
  PY_VERSION=$(docker run --rm -t ${IMAGE_NAME} python --version | grep -o "[0-9]\{1,2\}.[0-9]\{1,2\}.[0-9]\{1,2\}" | head -1)
  PYPI_VERSION=$(docker run --rm -t ${IMAGE_NAME} pip --version | cut -c1-14 | grep -o "[0-9]\{1,2\}.[0-9]\{1,2\}.[0-9]\{1,2\}" | head -1)
  if [ -z "${PYPI_VERSION}" ]; then
    PYPI_VERSION=$(docker run --rm -t ${IMAGE_NAME} pip --version | cut -c1-14 | grep -o "[0-9]\{1,2\}.[0-9]\{1,2\}" | head -1)
  fi
  echo "Docker:"
  echo "    Python: ${PY_VERSION}"
  echo "    Pip   : ${PYPI_VERSION}"
  echo ""

  if [ "${PY_VERSION}" = "${PYTHON_VERSION}" ] && [ "${PYPI_VERSION}" = "${PYTHON_PIP_VERSION}" ]; then
    echo "Docker and Local versions match. Doing nothing."
    exit 0
  else
    echo "Docker and Local versions mismatch. Building new image."
  fi
else
  echo "No docker build found on Hub. Building fresh image."
fi
echo ""

docker build -t ${IMAGE_NAME} --build-arg PYTHON_VERSION="${PYTHON_VERSION}" --build-arg PYTHON_PIP_VERSION="${PYTHON_PIP_VERSION}" .
if [ "${TRAVIS_BRANCH}" = "master" ] && [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  docker push ${IMAGE_NAME}
fi

