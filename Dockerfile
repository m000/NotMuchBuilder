FROM ubuntu:focal AS notmuch-deps
RUN apt-get update
RUN apt-get -y upgrade -o Dpkg::Options::="--force-confold"

# avoid interaction with tzdata config
ENV DEBIAN_FRONTEND=noninteractive

# debian packaging tools
RUN apt-get -y install \
	build-essential \
	dh-make \
	dh-python \
	dpkg-dev \
	fakeroot \
	sudo

# notmuch pre-requisites (basic build)
RUN apt-get -y install \
	install-info \
	libgmime-3.0-dev \
	libtalloc-dev \
	libxapian-dev \
	python3-sphinx \
	texinfo \
	zlib1g-dev

# notmuch extras (more features, testing)
RUN apt-get -y install \
	bash-completion \
	cppcheck \
	doxygen \
	gdb \
	python3-cffi \
	python3-dev \
	python3-pytest \
	python3-pytest-cov \
	python3-setuptools \
	xapian-tools

# other utilities
RUN apt-get -y install \
	git \
	vim-tiny \
	wget


FROM notmuch-deps AS notmuch-source
# create user
ARG USERNAME=notmuch
RUN useradd -m -s /bin/bash -G sudo ${USERNAME}
RUN echo "\n${USERNAME} ALL=NOPASSWD: ALL" >> /etc/sudoers
RUN chown ${USERNAME}:${USERNAME} /usr/src
# copy source
USER ${USERNAME}
ENV USER=${USERNAME}
ENV EMAIL="mstamat@gmail.com"
ENV DEBFULLNAME="Manolis Stamatogiannakis"
COPY --chown=${USERNAME}:${USERNAME} . /usr/src/notmuch
RUN mkdir -p /usr/src/notmuch.out
WORKDIR /usr/src/notmuch


FROM notmuch-source AS notmuch-build
# hack for dh_installman
RUN sed -i 's%^%debian/tmp/%' debian/*.manpages
CMD dpkg-buildpackage -rfakeroot -b && \
	dh_builddeb --dest=/usr/src/notmuch.out
