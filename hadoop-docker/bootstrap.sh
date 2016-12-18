#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp/*.pid

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/$2/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml

# altering the yatrn-site configuration
sed s/HOSTNAME/$2/ /usr/local/hadoop/etc/hadoop/yarn-site.xml.template > /usr/local/hadoop/etc/hadoop/yarn-site.xml

service sshd start
#$HADOOP_PREFIX/sbin/start-dfs.sh
#$HADOOP_PREFIX/sbin/start-yarn.sh
#$HADOOP_PREFIX/sbin/mr-jobhistory-daemon.sh start historyserver

if [[ $1 == "-d" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-bash" ]]; then
  /bin/bash
fi

if [[ $1 == "master" ]] ; then
  $HADOOP_PREFIX/bin/hdfs namenode -format
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start namenode
  $HADOOP_PREFIX/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start resourcemanager
  $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/bin/hdfs dfs -mkdir -p /user/root
  $HADOOP_PREFIX/etc/hadoop/hadoop-env.sh && $HADOOP_PREFIX/bin/hdfs dfs -put $HADOOP_PREFIX/etc/hadoop/ input
  while true; do sleep 1000; done
fi

if [[ $1 == "worker" ]]; then
  $HADOOP_PREFIX/sbin/hadoop-daemon.sh --config $HADOOP_CONF_DIR --script hdfs start datanode
  $HADOOP_PREFIX/sbin/yarn-daemon.sh --config $HADOOP_CONF_DIR start nodemanager
  while true; do sleep 1000; done
fi