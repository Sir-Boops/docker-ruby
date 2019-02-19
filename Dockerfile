FROM ubuntu:18.04

ENV JE_VER="5.1.0"
ENV RUBY_VER="2.6.1"

RUN echo "Etc/UTC" > /etc/localtime && \
	apt update && \
	apt -y dist-upgrade && \
	apt -y install wget make gcc g++ autoconf && \
	cd ~ && \
	wget https://github.com/jemalloc/jemalloc/archive/$JE_VER.tar.gz && \
	tar xf $JE_VER.tar.gz && \
	cd jemalloc-$JE_VER && \
	./autogen.sh && \
	./configure --prefix=/opt/jemalloc && \
	make -j$(nproc) && \
	make install_bin install_include install_lib

ENV CPPFLAGS="-I/opt/jemalloc/include"
ENV LDFLAGS="-L/opt/jemalloc/lib/"
RUN apt -y install zlib1g-dev libssl-dev \
		libgdbm-dev libdb-dev libreadline-dev && \
	cd ~ && \
	wget https://cache.ruby-lang.org/pub/ruby/${RUBY_VER%.*}/ruby-$RUBY_VER.tar.gz && \
	tar xf ruby-$RUBY_VER.tar.gz && \
	cd ruby-$RUBY_VER && \
	./configure --prefix=/opt/ruby \
		--with-jemalloc \
		--with-shared \
		--disable-install-doc && \
	ln -s /opt/jemalloc/lib/* /usr/lib/ && \
	make -j$(nproc) && \
	make install
