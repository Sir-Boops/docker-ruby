FROM alpine:3.11.3

ENV RUBY_VER="2.6.5"

RUN apk upgrade && \
	apk add gcc g++ make linux-headers \
		zlib-dev libressl-dev gdbm-dev \
		db-dev readline-dev dpkg \
		dpkg-dev patch && \
	cd ~ && \
	wget https://cache.ruby-lang.org/pub/ruby/${RUBY_VER%.*}/ruby-$RUBY_VER.tar.gz && \
	tar xf ruby-$RUBY_VER.tar.gz && \
	cd ruby-$RUBY_VER && \
	wget -O 'thread-stack-fix.patch' 'https://bugs.ruby-lang.org/attachments/download/7081/0001-thread_pthread.c-make-get_main_stack-portable-on-lin.patch' && \
	patch -p1 -i thread-stack-fix.patch && \
	ac_cv_func_isnan=yes ac_cv_func_isinf=yes \
		./configure --prefix=/opt/ruby \
			--build="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
			--disable-install-doc \
			--enable-shared && \ 
	make -j$(nproc) && \
	make install && \
	rm -rf /opt/ruby/share && \
	rm -rf ~/*
