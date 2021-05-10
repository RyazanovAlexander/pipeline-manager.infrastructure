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
	kubectl apply -f ./tidb/crd.yaml
	helm install --wait -n $(INFRASTRUCTURE_NAMESPACE) $(TIDB_RELEASE_NAME) ./tidb/tidb-operator-v1.1.12.tgz
	kubectl -n $(INFRASTRUCTURE_NAMESPACE) apply -f ./tidb/tidb-cluster.yaml
	kubectl -n $(INFRASTRUCTURE_NAMESPACE) apply -f ./tidb/tidb-monitor.yaml

#   prometheus-operator
	helm install --wait -n $(INFRASTRUCTURE_NAMESPACE) $(PROMETHEUS_OPERATOR_RELEASE_NAME) ./prometheus-operator/kube-prometheus-stack-15.4.4.tgz

#   keda
	helm install --wait -n $(INFRASTRUCTURE_NAMESPACE) $(KEDA_RELEASE_NAME) ./keda/keda-2.2.2.tgz

# ------------------------------------------------------------------------------
#  uninstall

.PHONY: uninstall
uninstall:
#   TiDB
	kubectl delete tc basic -n $(INFRASTRUCTURE_NAMESPACE)
	kubectl delete tidbmonitor basic -n $(INFRASTRUCTURE_NAMESPACE)
	kubectl delete pvc -n $(INFRASTRUCTURE_NAMESPACE) -l app.kubernetes.io/instance=basic,app.kubernetes.io/managed-by=tidb-operator
	kubectl get pv -l app.kubernetes.io/namespace=$(INFRASTRUCTURE_NAMESPACE),app.kubernetes.io/managed-by=tidb-operator,app.kubernetes.io/instance=basic -o name | xargs -I {} kubectl patch {} -p '{"spec":{"persistentVolumeReclaimPolicy":"Delete"}}'
	kubectl delete -f ./tidb/crd.yaml

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

#   keda
	helm uninstall -n $(INFRASTRUCTURE_NAMESPACE) $(KEDA_RELEASE_NAME)
	kubectl delete -f ./keda/keda.k8s.io_scaledobjects_crd.yaml

	kubectl delete ns $(INFRASTRUCTURE_NAMESPACE)