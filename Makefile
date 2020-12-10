IMAGE=markthebault/operators-catalog
OLM_VER=v0.17.0


build:
	docker build -t $(IMAGE) custom-catalog
	docker push $(IMAGE)

deploy:
	kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$(OLM_VER)/crds.yaml
	kubectl apply -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$(OLM_VER)/olm.yaml
	kubectl apply -f custom-catalog.yaml
	kubectl -n olm delete catalogsource operatorhubio-catalog

delete:
	kubectl delete -f custom-catalog.yaml || true
	###
	kubectl delete -n olm clusterserviceversion.operators.coreos.com/packageserver || true
	kubectl delete -n olm operatorgroup.operators.coreos.com/olm-operators || true
	sleep 15
	kubectl delete -n operators operatorgroup.operators.coreos.com/global-operators || true
	kubectl delete clusterrole.rbac.authorization.k8s.io/aggregate-olm-view || true
	kubectl delete clusterrole.rbac.authorization.k8s.io/aggregate-olm-edit || true
	kubectl delete -n olm deployment.apps/catalog-operator || true
	kubectl delete -n olm deployment.apps/olm-operator || true
	kubectl delete clusterrolebinding.rbac.authorization.k8s.io/olm-operator-binding-olm || true
	kubectl delete clusterrole.rbac.authorization.k8s.io/system:controller:operator-lifecycle-manager || true
	kubectl delete -n olm serviceaccount/olm-operator-serviceaccount || true

	kubectl delete -f https://github.com/operator-framework/operator-lifecycle-manager/releases/download/$(OLM_VER)/crds.yaml || true
	kubectl delete namespace/operators || true
	kubectl delete namespace/olm || true