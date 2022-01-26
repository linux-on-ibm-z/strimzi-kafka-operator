#!/usr/bin/env bash

if [ ! -f $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.19.3/rocksdbjni-6.19.3.jar ] || [ ! -f $HOME/.m2/repository/org/rocksdb/rocksdbjni/6.22.1.1/rocksdbjni-6.22.1.1.jar ]; then

export CUR_DIR=$(pwd)

#Install AdoptOpenJDK8 + OpenJ9 with Large heap
export CURPATH=$PATH
export S390X_JNI_JAR_DIR=$HOME/s390x_jni_jar
export PREFIX=/usr/local

cd $HOME
wget https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u282-b08_openj9-0.24.0/OpenJDK8U-jdk_s390x_linux_openj9_linuxXL_8u282b08_openj9-0.24.0.tar.gz
sudo tar zxf OpenJDK8U-jdk_s390x_linux_openj9_linuxXL_8u282b08_openj9-0.24.0.tar.gz -C /opt/
rm -rf OpenJDK8U-jdk_s390x_linux_openj9_linuxXL_8u282b08_openj9-0.24.0.tar.gz
export JAVA_HOME=/opt/jdk8u282-b08
export PATH=$JAVA_HOME/bin:$CURPATH

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

mkdir -p $S390X_JNI_JAR_DIR
git clone https://github.com/facebook/rocksdb.git
cp -r rocksdb rocksdb-6.19 && cd rocksdb-6.19/
ROCKSDB_VERSION=6.19.3
git checkout v$ROCKSDB_VERSION
curl -sSL https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/RocksDB/v$ROCKSDB_VERSION/patch/rocksdb.diff | patch -p1 || error "rocksdb_${ROCKSDB_VERSION}.diff"
PORTABLE=1 make -j$(nproc) rocksdbjavastatic
# Store rocksdbjni-6.19.3.jar in a temporary directory
cp -f java/target/rocksdbjni-$ROCKSDB_VERSION-linux64.jar $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar
sha1sum $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar > $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1
sed -i "s/ .*$//g" $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1
cp $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar $CUR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar
cp $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1 $CUR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1

# Build and Create rocksdbjni-6.22.1.jar for s390x
cd .. && mv rocksdb rocksdb-6.22 && cd rocksdb-6.22/
ROCKSDB_VERSION=6.22.1
git checkout v$ROCKSDB_VERSION
curl -sSL https://raw.githubusercontent.com/linux-on-ibm-z/scripts/master/RocksDB/v$ROCKSDB_VERSION/patch/rocksdb.diff | patch -p1 || error "rocksdb_${ROCKSDB_VERSION}.diff"
PORTABLE=1 make -j$(nproc) rocksdbjavastatic
# Store rocksdbjni-6.22.1.jar in a temporary directory
ROCKSDB_VERSION=6.22.1.1
cp -f java/target/rocksdbjni-6.22.1-linux64.jar $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar
sha1sum $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar > $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1
sed -i "s/ .*$//g" $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1
cp $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar $CUR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar
cp $S390X_JNI_JAR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1 $CUR_DIR/rocksdbjni-$ROCKSDB_VERSION.jar.sha1

export PATH=$CURPATH

fi