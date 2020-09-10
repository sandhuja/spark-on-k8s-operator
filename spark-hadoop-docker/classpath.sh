for f in $SPARK_HOME/jars/logging/*.jar; do
  if [ "$SPARK_CLASSPATH" ]; then
    export SPARK_CLASSPATH=$SPARK_CLASSPATH:$f
  else
    export SPARK_CLASSPATH=$f
  fi
done


export SPARK_DIST_CLASSPATH=$(hadoop classpath)
export HADOOP_CLASSPATH=$SPARK_DIST_CLASSPATH
export SPARK_CLASSPATH=$SPARK_CLASSPATH:$SPARK_DIST_CLASSPATH
