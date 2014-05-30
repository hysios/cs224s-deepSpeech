#! /bin/bash

#source "$APP_HOME/setup_database.sh"
export APP_HOME=`pwd`
# export DEEPDIVE_HOME=`cd ../..; pwd`
export DEEPDIVE_HOME=`cd $(dirname $0)/../..; pwd`

export EVAL_BASE=$APP_HOME/speech-data/output/
# source env.sh

if [ -f $DEEPDIVE_HOME/sbt/sbt ]; then
  echo "DeepDive $DEEPDIVE_HOME"
else
  echo "[ERROR] Could not find sbt in $DEEPDIVE_HOME!"
  exit 1
fi

cd $DEEPDIVE_HOME
# $DEEPDIVE_HOME/sbt/sbt "run -c $APP_HOME/application.conf"
deepdive -c $APP_HOME/evaluation.conf

echo "Exporting lattice data..."

psql --tuples-only -d $DBNAME -c "
select array_to_string(words, ' ') || ' (' || speaker_id || '_' || sentenceid || ')' 
from  output_bestpath c,
      lattice_meta m
where c.lattice_id = m.lattice_id
order by c.lattice_id
;" > $EVAL_BASE/dd-output.trn

psql -d $DBNAME -c "
select array_to_string(words, ' ') || ' (' || speaker_id || '_' || sentenceid || ')' 
from  transcript_array c,
      lattices_holdout h,
      lattice_meta m
where c.lattice_id = m.lattice_id
and   c.lattice_id = h.lattice_id   -- part of holdout doc
order by c.lattice_id
"  > $EVAL_BASE/transcript.trn

# sclite -r $EVAL_BASE/transcript.trn -h $EVAL_BASE/dd-output.trn -i wsj
sclite -r $EVAL_BASE/transcript.trn -h $EVAL_BASE/dd-output.trn -i rm >$EVAL_BASE/eval-result.txt

grep 'SPKR' $EVAL_BASE/eval-result.txt
grep 'Sum/Avg' $EVAL_BASE/eval-result.txt