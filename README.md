# security-take-home-assignment

## What is in the project
- Kubernetes Cluster
- Database

## What should be done
- [ ] Connect Kubernetes Cluster to Database
- [ ] Store credentials in a secure place like secret manager
- [ ] Audit current firewall rules and make sure only necessary ports are open
- [ ] Improve security of the cluster and database
- [ ] Create and deploy an app to kubernetes cluster that connects to the database

## How to run 
```
make kubernetes.init
make kubernetes.plan
make kubernetes.apply
make database.init
make database.plan
make database.apply
```
