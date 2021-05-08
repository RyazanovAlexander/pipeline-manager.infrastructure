INFRASTRUCTURE_NAMESPACE ?= infrastructure

PROMETHEUS_OPERATOR_RELEASE_NAME := prometheus-operator
KEDA_RELEASE_NAME                := keda
TIDB_RELEASE_NAME                := tidb

# ------------------------------------------------------------------------------
#  install

.PHONY: install
install:
	kubectl create ns infrastructure
#   TiDB
#	kubectl apply -f https://raw.githubusercontent.com/pingcap/tidb-operator/master/manifests/crd.yaml
#	helm repo add pingcap https://charts.pingcap.org/
#	helm repo update
#	kubectl create namespace tidb-admin
#	helm install --wait --namespace tidb-admin tidb-operator pingcap/tidb-operator --version v1.2.0-beta.2
#	kubectl create namespace tidb-cluster
#	kubectl -n tidb-cluster apply -f https://raw.githubusercontent.com/pingcap/tidb-operator/master/examples/basic/tidb-cluster.yaml
#	curl -LO https://raw.githubusercontent.com/pingcap/tidb-operator/master/examples/basic/tidb-monitor.yaml
#	kubectl -n tidb-cluster apply -f tidb-monitor.yaml

#   prometheus-operator
	helm install --wait -n $(INFRASTRUCTURE_NAMESPACE) $(PROMETHEUS_OPERATOR_RELEASE_NAME) ./prometheus-operator/kube-prometheus-stack-15.4.4.tgz

# ------------------------------------------------------------------------------
#  uninstall

.PHONY: uninstall
uninstall:
#   TiDB
#	kubectl delete tc basic -n tidb-cluster
#	kubectl delete tidbmonitor basic -n tidb-cluster
#	kubectl delete pvc -n tidb-cluster -l app.kubernetes.io/instance=basic,app.kubernetes.io/managed-by=tidb-operator
#	kubectl get pv -l app.kubernetes.io/namespace=tidb-cluster,app.kubernetes.io/managed-by=tidb-operator,app.kubernetes.io/instance=basic -o name | xargs -I {} kubectl patch {} -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
#	kubectl delete -f https://raw.githubusercontent.com/pingcap/tidb-operator/master/manifests/crd.yaml
#	kubectl delete ns tidb-cluster
#	kubectl delete ns tidb-admin

#   prometheus-operator
	helm uninstall -n $(INFRASTRUCTURE_NAMESPACE) $(PROMETHEUS_OPERATOR_RELEASE_NAME)
	kubectl delete crd alertmanagerconfigs.monitoring.coreos.com
	kubectl delete crd alertmanagers.monitoring.coreos.com
	kubectl delete crd podmonitors.monitoring.coreos.com
	kubectl delete crd probes.monitoring.coreos.com
	kubectl delete crd prometheuses.monitoring.coreos.com
	kubectl delete crd prometheusrules.monitoring.coreos.com
	kubectl delete crd servicemonitors.monitoring.coreos.com
	kubectl delete crd thanosrulers.monitoring.coreos.com

	kubectl delete ns $(INFRASTRUCTURE_NAMESPACE)