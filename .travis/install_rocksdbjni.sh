#!/usr/bin/env bash

export CURPATH=$PATH
export S390X_JNI_JAR_DIR=$HOME/s390x_jni_jar
export PREFIX=/usr/local

if [ ! -f $HOME/s390x_jni_jar/rocksdbjni-6.19.3.jar ]; then
	printf -- "Building rocksdbjni jars \n"
	#Install AdoptOpenJDK8 + OpenJ9 with Large heap
	cd $HOME
	wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u282-b08_openj9-0.24.0/OpenJDK8U-jdk_s390x_linux_openj9_linuxXL_8u282b08_openj9-0.24.0.tar.gz
	sudo tar zxf OpenJDK8U-jdk_s390x_linux_openj9_linuxXL_8u282b08_openj9-0.24.0.tar.gz -C /opt/
	rm -rf OpenJDK8U-jdk_s390x_linux_openj9_linuxXL_8u282b08_openj9-0.24.0.tar.gz
	export JAVA_HOME=/opt/jdk8u282-b08
	export PATH=$JAVA_HOME/bin:$CURPATH

	# Build and Create rocksdbjni-5.18.4.jar for s390x
	git clone https://github.com/facebook/rocksdb.git
	cp -r rocksdb rocksdb-5 && cd rocksdb-5/
	git checkout v5.18.4
	sed -i '1656s/ARCH/MACHINE/g' Makefile
	PORTABLE=1 make shared_lib
	make rocksdbjava
	mkdir -p $S390X_JNI_JAR_DIR
	# Store rocksdbjni-5.18.4.jar in a temporary directory
	cp -f java/target/rocksdbjni-5.18.4-linux64.jar $S390X_JNI_JAR_DIR/rocksdbjni-5.18.4.jar
	sha1sum $S390X_JNI_JAR_DIR/rocksdbjni-5.18.4.jar > $S390X_JNI_JAR_DIR/rocksdbjni-5.18.4.jar.sha1
	sed -i "s/ .*$//g" $S390X_JNI_JAR_DIR/rocksdbjni-5.18.4.jar.sha1

	# Install gflags 2.0
	cd $HOME
	git clone -b v2.0 https://github.com/gflags/gflags.git
	cd gflags
	./configure --prefix="$PREFIX"
	make
	sudo make install
	sudo ldconfig /usr/local/lib
	rm -rf $HOME/gflags

	# Build and Create rocksdbjni-6.19.3.jar for s390x
	cd $HOME
	mv rocksdb rocksdb-6 && cd rocksdb-6/
	git checkout v6.19.3
	PORTABLE=1 make -j$(nproc) rocksdbjavastatic
	# Store rocksdbjni-6.19.3.jar in a temporary directory
	cp -f java/target/rocksdbjni-6.19.3-linux64.jar $S390X_JNI_JAR_DIR/rocksdbjni-6.19.3.jar
	sha1sum $S390X_JNI_JAR_DIR/rocksdbjni-6.19.3.jar > $S390X_JNI_JAR_DIR/rocksdbjni-6.19.3.jar.sha1
	sed -i "s/ .*$//g" $S390X_JNI_JAR_DIR/rocksdbjni-6.19.3.jar.sha1
fi

# Install and setup Maven
export PATH=$CURPATH
cd $HOME
wget https://archive.apache.org/dist/maven/maven-3/3.8.2/binaries/apache-maven-3.8.2-bin.tar.gz
tar -zxf apache-maven-3.8.2-bin.tar.gz
export PATH=$HOME/apache-maven-3.8.2/bin:$PATH

# Put locally built jni jars in the local maven repository
mkdir -p $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3
cp -f $S390X_JNI_JAR_DIR/rocksdbjni-6.19.3.jar $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3/rocksdbjni-6.19.3.jar
cp -f $S390X_JNI_JAR_DIR/rocksdbjni-6.19.3.jar.sha1 $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3/rocksdbjni-6.19.3.jar.sha1
