blueprint defaults
cluster build --blueprint  multi-node-hdfs-yarn
cluster assign --host bal-felso.mycorp.kom --hostGroup master
cluster assign --hostGroup slaves --host bal-also.mycorp.kom
cluster assign --hostGroup slaves --host jobb-felso.mycorp.kom
cluster assign --hostGroup slaves --host jobbalso.mycorp.kom
cluster create
