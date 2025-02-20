all: blockchain faucet blockchain-data-manager frontend explorer

clean:
	-nomad job stop -purge blockchain
	-nomad job stop -purge blockchain-data-manager
	-nomad job stop -purge explorer
	-nomad job stop -purge frontend
	-nomad system reconcile summaries

blockchain:
	@echo "» No building necessary for Blockchain"
	@echo "» Deploying Blockchain"
	nomad job run jobs/blockchain.nomad

faucet:
	@echo "» Building Faucet"
	docker build -t gcr.io/alexis-de-la-torre/faucet components/faucet
	docker push gcr.io/alexis-de-la-torre/faucet
	@echo "» Deploying Faucet"
	nomad job run jobs/faucet.nomad

blockchain-data-manager:
	@echo "» Building Blockchain Data Manager"
	cd components/blockchain-data-manager; mvn -Dmaven.test.skip spring-boot:build-image
	docker tag blockchain-data-manager:0.0.1-SNAPSHOT gcr.io/alexis-de-la-torre/blockchain-data-manager
	docker push gcr.io/alexis-de-la-torre/blockchain-data-manager
	@echo "» Building Bootstraper"
	docker build -t gcr.io/alexis-de-la-torre/bootstraper components/bootstraper
	docker push gcr.io/alexis-de-la-torre/bootstraper
	@echo "» Deploying Blockchain Data Manager"
	nomad job run jobs/blockchain-data-manager.nomad

frontend:
	@echo "» Building Frontend"
	docker build -t gcr.io/alexis-de-la-torre/frontend components/frontend
	docker push gcr.io/alexis-de-la-torre/frontend
	@echo "» Deploying Frontend"
	nomad job run jobs/frontend.nomad

explorer:
	@echo "» Building Explorer"
	docker build -t gcr.io/alexis-de-la-torre/explorer:1.0.0 components/explorer
	docker push gcr.io/alexis-de-la-torre/explorer:1.0.0
	@echo "» Deploying Explorer"
	nomad job run jobs/explorer.nomad

.PHONY: all blockchain faucet blockchain-data-manager frontend explorer
