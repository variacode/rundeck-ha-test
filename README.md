# rundeck-ha-test

This project executes a DR test on rundeck pro.
Using docker-compose, this test will build 2 independent rundeck nodes, with an active-passive configuration, using the Job Replication SCM plugin.
The test will check the platform starts OK, then will kill the primary node, and check that an scheduled job starts to work on node 2.

##SETUP:

- You need docker 1.10+ and docker-compose 1.7+ to run the tests.
- You need an internet connection.
- You need to import the rundeckpro-installer sourcebase into ./dockers/rundeck/rundeckpro-installer and configure its metadata properly.

##TO RUN:

just run: `./run.sh`

##Other Commands:

### To watch the server logs while tests are running.
`docker-compose -f <test docker-compose yml> logs -f`

### To bring up the platform without running the tests:
`docker-compose -f <test docker-compose yml> build; docker-compose up`

### To login into the machines
#### node 1
`docker-compose -f <test docker-compose yml> exec rundeck1 bash -l`
#### node 2
`docker-compose -f <test docker-compose yml> exec rundeck2 bash -l`
#### test observer
`docker-compose -f <test docker-compose yml> exec testnode bash -l`


### To run the tests manually
`./scripts/run-tests.sh`


### To clear all container info including storage volumes
`./clean.sh`



