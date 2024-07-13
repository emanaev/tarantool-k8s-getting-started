TAG=tarantool/getting-started-app:0.1

build:
	cartridge build
	cartridge pack docker --tag $(TAG)

up:
	minikube start
	helm repo add tarantool https://tarantool.github.io/helm-charts/
	helm upgrade --install tarantool-operator-ce tarantool/tarantool-operator -n tarantool-operator --create-namespace
	kubectl wait --for=condition=Available deployment tarantool-operator-ce -n tarantool-operator --timeout=600s
	kubectl get pods -n tarantool-operator

down:
	minikube delete

load:
	docker image save $(TAG) -o /tmp/tmp.tar
	./minikube-load.sh /tmp/tmp.tar

restart: down up load start

start:
	helm upgrade --install tarantool-app tarantool/cartridge --values values.yaml -n example --create-namespace
	kubectl wait cluster.tarantool.io tarantool-app-cartridge -n example --for=jsonpath='{.status.phase}'=Ready --timeout=600s
	kubectl get svc -n example

tunnel:
	kubectl port-forward svc/tarantool-app-cartridge-role-api 8081 -n example
