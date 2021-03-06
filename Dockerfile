# Builds off of https://github.com/docker-library/python/blob/master/3.6/stretch/slim/Dockerfile

FROM debian:stretch-slim

ARG PYTHON_VERSION
# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ARG PYTHON_PIP_VERSION

# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8
ENV PYTHONIOENCODING UTF-8

RUN PY_VERSION=$(echo "${PYTHON_VERSION}" | cut -c1-3 -); \
  if [ "${PY_VERSION}" = "3.3" ] || [ "${PY_VERSION}" = "3.4" ]; then \
    apt-get update; \
    apt-get install -y --no-install-recommends wget; \
    wget http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb -O /tmp/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb; \
    apt-get purge --auto-remove -y wget; \
    dpkg --install /tmp/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb; \
    rm -rf /tmp/libssl1.0.0_1.0.1t-1+deb8u8_amd64.deb; \
  else \
    apt-get install -y --no-install-recommends libssl1.1; \
  fi; \
  rm -rf /var/lib/apt/lists/*

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		libexpat1 \
		libffi6 \
		libgdbm3 \
		libreadline7 \
		libsqlite3-0 \
		netbase \
	&& rm -rf /var/lib/apt/lists/*

RUN set -ex \
  && dpkg-query -l 'libssl*' \
  && PY_VERSION=$(echo "${PYTHON_VERSION}" | cut -c1-3 -) \
  && GPG_KEY="0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D" \
  && [ "${PY_VERSION}" = "2.7" ] && GPG_KEY="C01E1CAD5EA2C4F0B8E3571504C367C218ADD4FF" || : \
  && [ "${PY_VERSION}" = "3.3" ] && GPG_KEY="0a5b101836580288" || : \
  && [ "${PY_VERSION}" = "3.4" ] && GPG_KEY="97FC712E4C024BBEA48A61ED3A5CA953F73C700D" || : \
  && [ "${PY_VERSION}" = "3.5" ] && GPG_KEY="97FC712E4C024BBEA48A61ED3A5CA953F73C700D" || : \
	&& buildDeps=" \
		dpkg-dev \
		gcc \
		libbz2-dev \
		libc6-dev \
		libexpat1-dev \
		libffi-dev \
		libgdbm-dev \
		liblzma-dev \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		make \
		tcl-dev \
		tk-dev \
		wget \
		xz-utils \
		zlib1g-dev \
# as of Stretch, "gpg" is no longer included by default
		$(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
	" \
	&& apt-get update && apt-get install -y $buildDeps --no-install-recommends && rm -rf /var/lib/apt/lists/*; \
  if [ "${PY_VERSION}" = "3.3" ] || [ "${PY_VERSION}" = "3.4" ]; then \
    apt-get purge -y --auto-remove libssl-dev; \
    wget http://ftp.us.debian.org/debian/pool/main/o/openssl/libssl-dev_1.0.1t-1+deb8u8_amd64.deb -O /tmp/libssl-dev_1.0.1t-1+deb8u8_amd64.deb; \
    dpkg --install /tmp/libssl-dev_1.0.1t-1+deb8u8_amd64.deb; \
    rm -rf /tmp/libssl-dev_1.0.1t-1+deb8u8_amd64.deb; \
  fi; \
	wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-${PYTHON_VERSION}.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
		|| gpg --batch --keyserver ipv4.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& ldconfig \
	&& apt-get purge -y --auto-remove $buildDeps \
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' + \
	&& rm -rf /usr/src/python

# make some useful symlinks that are expected to exist
RUN PYTHON_MAJOR=$(echo "${PYTHON_VERSION}" | cut -c1 -) \
  && cd /usr/local/bin \
  && rm -rf idle pydoc python python-config \
	&& ln -s "idle${PYTHON_MAJOR}" idle \
	&& ln -s "pydoc${PYTHON_MAJOR}" pydoc \
	&& ln -s "python${PYTHON_MAJOR}" python \
	&& ln -s "python${PYTHON_MAJOR}-config" python-config

RUN set -ex; \
	apt-get update; \
	apt-get install -y --no-install-recommends wget; \
	rm -rf /var/lib/apt/lists/*; \
	wget -O get-pip.py 'https://bootstrap.pypa.io/get-pip.py'; \
	apt-get purge -y --auto-remove wget; \
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py

CMD ["/usr/local/bin/python"]
